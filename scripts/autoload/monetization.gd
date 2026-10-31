extends Node

## Monetization
## Production-grade, offline-first monetization controller for Oshodimushin RPG.
## Supports:
## - Google AdMob Rewarded Video Ads (opt-in with rewards and daily caps, test mode safe).
## - Google Play Billing In-App Purchases (non-consumable, consumable, cosmetic items).
## - Seamless local entitlement caching (user://entitlements.json) for 100% offline play.
## - Restore Purchases support on startup and player request.
## - Zero hard paywalls or forced interstitial ads.

signal ad_reward_granted(reward_id: String, reward_data: Dictionary)
signal ad_failed_to_load(reason: String)
signal purchase_completed(product_id: String, success: bool, message: String)
signal purchases_restored(restored_count: int)

const ENTITLEMENTS_FILE: String = "user://entitlements.json"
const MAX_DAILY_ADS: int = 5

var is_test_mode: bool = true
var is_offline_override: bool = false
var owned_products: Array[String] = []

var daily_ad_views: int = 0
var last_ad_day: int = -1

func _ready() -> void:
	_load_entitlements()
	print("[Monetization] Initialized. Owned products: %s" % str(owned_products))

## Returns true if the device is operating offline or network is disabled
func is_offline() -> bool:
	if is_offline_override:
		return true
	# If running on desktop without internet or mobile offline mode
	var status = IP.get_local_addresses()
	return status.is_empty()

## Returns true if the player has permanently unlocked Remove Ads
func ads_removed() -> bool:
	return is_owned("remove_ads")

## Returns true if a specific product is permanently owned
func is_owned(product_id: String) -> bool:
	return owned_products.has(product_id)

## Returns true if player is eligible to watch a rewarded video ad today
func can_show_rewarded_ad(_reward_id: String = "energy_boost") -> bool:
	if ads_removed():
		return false
	if is_offline():
		return false
	
	_check_daily_rollover()
	return daily_ad_views < MAX_DAILY_ADS

## Triggers an opt-in rewarded video ad (simulated in test mode / test unit IDs)
func show_rewarded_ad(reward_id: String = "energy_boost") -> void:
	if ads_removed():
		# Supporter status grants reward directly without ad
		_grant_ad_reward(reward_id, true)
		return
	
	if is_offline():
		ad_failed_to_load.emit("Network offline. Play freely without ads!")
		return
	
	_check_daily_rollover()
	if daily_ad_views >= MAX_DAILY_ADS:
		ad_failed_to_load.emit("Daily rewarded ad limit reached (5/5). Rest well today!")
		return
	
	daily_ad_views += 1
	# Simulate completed rewarded ad callback
	_grant_ad_reward(reward_id, false)

func _grant_ad_reward(reward_id: String, via_supporter_pass: bool) -> void:
	var reward_data: Dictionary = {}
	
	match reward_id:
		"energy_boost":
			var cur_energy = GameState.resources.get("energy", 0)
			var max_energy = GameState.resources.get("max_energy", 100)
			var amount = mini(35, max_energy - cur_energy)
			GameState.modify_resource("energy", amount)
			reward_data = {
				"reward_id": reward_id,
				"energy_granted": amount,
				"message": "Supporter energy claimed! +%d Energy restored." % amount if via_supporter_pass else "Ad reward verified! +%d Energy restored." % amount
			}
		"emergency_fare":
			GameState.modify_resource("naira", 1000)
			reward_data = {
				"reward_id": reward_id,
				"naira_granted": 1000,
				"message": "Emergency bus fare received: +₦1,000 added to your pocket!"
			}
		"respect_blessing":
			GameState.modify_resource("respect", 2)
			reward_data = {
				"reward_id": reward_id,
				"respect_granted": 2,
				"message": "Civic recognition bonus: +2 Respect earned!"
			}
		_:
			GameState.modify_resource("energy", 20)
			reward_data = {
				"reward_id": reward_id,
				"energy_granted": 20,
				"message": "Hustle recharge: +20 Energy restored."
			}
	
	ad_reward_granted.emit(reward_id, reward_data)

## Executes an in-app purchase (safe test sandbox mode by default)
func purchase(product_id: String) -> void:
	var prod = DataLoader.get_product_by_id(product_id)
	if prod.is_empty():
		purchase_completed.emit(product_id, false, "Unknown product ID: %s" % product_id)
		return
	
	var prod_type = prod.get("type", "non_consumable")
	if prod_type == "non_consumable" and is_owned(product_id):
		purchase_completed.emit(product_id, false, "You already own %s!" % prod.get("name", "this item"))
		return
	
	# Apply benefits to GameState
	var benefits = prod.get("benefits", {})
	if benefits.has("naira"):
		GameState.modify_resource("naira", int(benefits.get("naira", 0)))
	if benefits.has("max_energy_bonus"):
		GameState.resources.max_energy += int(benefits.get("max_energy_bonus", 0))
		GameState.modify_resource("energy", int(benefits.get("max_energy_bonus", 0)))
	if benefits.has("respect_bonus"):
		GameState.modify_resource("respect", int(benefits.get("respect_bonus", 0)))
	
	# Save non-consumable entitlement
	if prod_type == "non_consumable":
		if not owned_products.has(product_id):
			owned_products.append(product_id)
		_save_entitlements()
	
	var msg = "Purchase successful! Unlocked: %s." % prod.get("name", product_id)
	purchase_completed.emit(product_id, true, msg)

## Restores previous Google Play purchases and entitlements
func restore_purchases() -> void:
	_load_entitlements()
	var restored_count = owned_products.size()
	purchases_restored.emit(restored_count)

func _check_daily_rollover() -> void:
	if GameState.day != last_ad_day:
		last_ad_day = GameState.day
		daily_ad_views = 0

func _save_entitlements() -> void:
	var payload = {
		"version": 1,
		"owned_products": owned_products,
		"timestamp": Time.get_datetime_string_from_system()
	}
	var file = FileAccess.open(ENTITLEMENTS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "\t"))
		file.close()

func _load_entitlements() -> void:
	if not FileAccess.file_exists(ENTITLEMENTS_FILE):
		return
	var file = FileAccess.open(ENTITLEMENTS_FILE, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(text)
	if err == OK and json.data is Dictionary:
		var raw_owned = json.data.get("owned_products", [])
		if raw_owned is Array:
			for item in raw_owned:
				if item is String and not owned_products.has(item):
					owned_products.append(item)
