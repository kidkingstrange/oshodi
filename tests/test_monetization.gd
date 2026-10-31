class_name TestMonetization
extends RefCounted

## Unit tests for Phase 9: Fair Monetization, In-App Purchases & Rewarded Ads

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_products_catalog()
	test_purchase_non_consumable()
	test_purchase_consumable()
	test_restore_purchases()
	test_rewarded_ad_grant()
	test_daily_ad_cap()
	test_offline_mode_safety()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_products_catalog() -> void:
	var prods = DataLoader.get_all_products()
	_assert_true(prods.size() >= 4, "At least 4 in-app products loaded from data/products.json (got %d)" % prods.size())
	
	var remove_ads = DataLoader.get_product_by_id("remove_ads")
	_assert_true(not remove_ads.is_empty(), "Product 'remove_ads' exists in catalog")
	_assert_true(remove_ads.get("type", "") == "non_consumable", "Product 'remove_ads' is non_consumable")
	_assert_true(int(remove_ads.get("price_naira", 0)) > 0, "Product 'remove_ads' has valid naira price")

func test_purchase_non_consumable() -> void:
	GameState.create_character("Buyer", "trader")
	# Ensure clean state
	Monetization.owned_products.clear()
	
	Monetization.purchase("remove_ads")
	_assert_true(Monetization.is_owned("remove_ads"), "Product 'remove_ads' is marked as owned")
	_assert_true(Monetization.ads_removed(), "ads_removed() returns true after purchase")
	_assert_true(FileAccess.file_exists(Monetization.ENTITLEMENTS_FILE), "Entitlements file saved locally for offline play")

func test_purchase_consumable() -> void:
	GameState.create_character("Buyer", "trader")
	var old_naira = GameState.resources.naira
	var old_max_energy = GameState.resources.max_energy
	
	Monetization.purchase("starter_hustle_pack")
	_assert_true(GameState.resources.naira == old_naira + 10000, "Starter pack credited ₦10,000 cash bonus")
	_assert_true(GameState.resources.max_energy == old_max_energy + 20, "Starter pack expanded max energy capacity by +20")

func test_restore_purchases() -> void:
	# Simulate new session: clear memory owned products
	Monetization.owned_products.clear()
	_assert_true(not Monetization.is_owned("remove_ads"), "Owned products cleared in memory")
	
	Monetization.restore_purchases()
	_assert_true(Monetization.is_owned("remove_ads"), "restore_purchases() successfully restored 'remove_ads' from entitlements")
	_assert_true(Monetization.ads_removed(), "ads_removed() remains true after restoration")

func test_rewarded_ad_grant() -> void:
	GameState.create_character("AdWatcher", "trader")
	GameState.resources.energy = 20
	Monetization.owned_products.clear() # Temporarily not a supporter to test ad view
	Monetization.daily_ad_views = 0
	Monetization.last_ad_day = GameState.day
	
	var initial_energy = GameState.resources.energy
	Monetization.show_rewarded_ad("energy_boost")
	_assert_true(GameState.resources.energy == initial_energy + 35, "Rewarded ad granted +35 Energy boost (20 -> 55)")
	_assert_true(Monetization.daily_ad_views == 1, "Daily ad counter incremented to 1")

func test_daily_ad_cap() -> void:
	GameState.create_character("AdWatcher", "trader")
	Monetization.owned_products.clear()
	Monetization.last_ad_day = GameState.day
	Monetization.daily_ad_views = 5
	
	_assert_true(not Monetization.can_show_rewarded_ad("energy_boost"), "can_show_rewarded_ad returns false when daily cap (5) is reached")

func test_offline_mode_safety() -> void:
	GameState.create_character("OfflinePlayer", "trader")
	Monetization.owned_products.clear()
	Monetization.is_offline_override = true
	
	_assert_true(Monetization.is_offline(), "is_offline() reports true")
	_assert_true(not Monetization.can_show_rewarded_ad("energy_boost"), "Ads are disabled when offline")
	
	var state = {"received": false}
	var error_callable = func(reason: String):
		state["received"] = true
	Monetization.ad_failed_to_load.connect(error_callable)
	
	Monetization.show_rewarded_ad("energy_boost")
	_assert_true(state["received"], "Graceful offline notification emitted without crashing")
	Monetization.ad_failed_to_load.disconnect(error_callable)
	
	Monetization.is_offline_override = false
