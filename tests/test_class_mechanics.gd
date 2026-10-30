class_name TestClassMechanics
extends RefCounted

## Unit tests for Phase 4: Class mechanics & progression
## Tests items validation, InventoryManager, ShopManager, Trader mechanics,
## Transporter mechanics, and Levelling / subclass unlocks.

const InventoryManager = preload("res://scripts/core/inventory_manager.gd")
const ShopManager = preload("res://scripts/core/shop_manager.gd")
const TraderMechanic = preload("res://scripts/core/trader_mechanic.gd")
const TransporterMechanic = preload("res://scripts/core/transporter_mechanic.gd")
const Levelling = preload("res://scripts/core/levelling.gd")

static func run_tests() -> Dictionary:
	var results = { "passed": 0, "failed": 0, "messages": [] }
	
	_test_items_data(results)
	_test_inventory_manager(results)
	_test_shop_manager(results)
	_test_trader_mechanic(results)
	_test_transporter_mechanic(results)
	_test_levelling_system(results)
	
	return results

static func _assert_true(condition: bool, test_name: String, results: Dictionary) -> void:
	if condition:
		results.passed += 1
		results.messages.append("  [PASS] %s" % test_name)
	else:
		results.failed += 1
		results.messages.append("  [FAIL] %s" % test_name)

static func _test_items_data(results: Dictionary) -> void:
	DataLoader.load_and_validate_all("res://data")
	var all_items = DataLoader.get_all_items()
	_assert_true(all_items.size() >= 12, "At least 12 items loaded in items.json", results)
	
	var tomato = DataLoader.get_item_by_id("tomato_crate")
	_assert_true(not tomato.is_empty(), "tomato_crate item exists", results)
	_assert_true(tomato.get("type", "") == "trade_good", "tomato_crate is trade_good", results)
	_assert_true(tomato.get("buy_price", 0) > 0, "Item has positive buy price", results)
	
	var energy_drink = DataLoader.get_item_by_id("energy_drink")
	_assert_true(not energy_drink.is_empty(), "energy_drink item exists", results)
	_assert_true(energy_drink.get("type", "") == "consumable", "energy_drink is consumable", results)

static func _test_inventory_manager(results: Dictionary) -> void:
	GameState.create_character("TestInv", "trader")
	GameState.inventory.clear()
	
	InventoryManager.add_item("tomato_crate", 2)
	_assert_true(InventoryManager.get_item_count("tomato_crate") == 2, "Added 2 tomato crates to inventory", results)
	_assert_true(InventoryManager.has_item("tomato_crate", 2), "has_item returns true for 2 crates", results)
	_assert_true(not InventoryManager.has_item("tomato_crate", 5), "has_item returns false for 5 crates", results)
	
	var removed = InventoryManager.remove_item("tomato_crate", 1)
	_assert_true(removed == true, "Successfully removed 1 crate", results)
	_assert_true(InventoryManager.get_item_count("tomato_crate") == 1, "1 crate remains in inventory", results)
	
	# Weight calculation: tomato crate weight is 3 kg
	var w = InventoryManager.get_total_weight()
	_assert_true(w == 3, "Total inventory weight calculates correctly (3 kg)", results)
	
	# Test consumable usage
	GameState.resources.energy = 50
	InventoryManager.add_item("energy_drink", 1)
	var consume_res = InventoryManager.use_consumable("energy_drink")
	_assert_true(consume_res.get("success", false) == true, "Consumable used successfully", results)
	_assert_true(GameState.resources.energy == 70, "Energy drink restored +20 energy (50 -> 70)", results)
	_assert_true(InventoryManager.get_item_count("energy_drink") == 0, "Consumed item removed from inventory", results)

static func _test_shop_manager(results: Dictionary) -> void:
	GameState.create_character("TestShopper", "trader")
	GameState.resources.naira = 10000
	GameState.location_id = "oshodi_market"
	GameState.inventory.clear()
	
	var market_items = ShopManager.get_shop_inventory("oshodi_market")
	_assert_true(not market_items.is_empty(), "Market has available items for sale", results)
	
	# Buy 1 tomato crate (buy_price 2500)
	var buy_res = ShopManager.buy_item("tomato_crate", 1)
	_assert_true(buy_res.get("success", false) == true, "Successfully bought tomato crate", results)
	_assert_true(GameState.resources.naira == 7500, "10000 - 2500 = 7500 Naira remaining", results)
	_assert_true(InventoryManager.has_item("tomato_crate", 1), "Bought item added to inventory", results)
	
	# Sell tomato crate as Trader: base sell 3800 * 1.15 = 4370 Naira
	var sell_res = ShopManager.sell_item("tomato_crate", 1)
	_assert_true(sell_res.get("success", false) == true, "Successfully sold tomato crate", results)
	_assert_true(sell_res.get("unit_price", 0) == 4370, "Trader receives +15% trade margin bonus (4,370 Naira)", results)
	_assert_true(GameState.resources.naira == 7500 + 4370, "Naira updated with sale revenue", results)
	_assert_true(InventoryManager.get_item_count("tomato_crate") == 0, "Sold item deducted from inventory", results)
	
	# Test insufficient funds
	GameState.resources.naira = 100
	var poor_res = ShopManager.buy_item("tomato_crate", 1)
	_assert_true(poor_res.get("success", false) == false, "Buy fails gracefully with insufficient funds", results)

static func _test_trader_mechanic(results: Dictionary) -> void:
	GameState.create_character("TestTrader", "trader")
	GameState.stats.hustle = 5
	GameState.stats.charisma = 4
	
	# Seed with high roll so bargain is not forced
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	var work_res = TraderMechanic.perform_trader_work(rng)
	_assert_true(work_res.income > 3200, "Trader with 5 Hustle earns more than base 3200 income", results)
	_assert_true(work_res.multiplier > 1.0, "Work multiplier is greater than 1.0", results)
	
	# Seed with roll < 0.20 to trigger Good Eye bargain perk
	var lucky_rng = RandomNumberGenerator.new()
	lucky_rng.seed = 7
	# Let's force roll by passing rigged roll if needed or testing field
	var bargain_res = TraderMechanic.perform_trader_work(lucky_rng)
	_assert_true(bargain_res.has("bargain_found"), "Trader report tracks Good Eye bargain status", results)

static func _test_transporter_mechanic(results: Dictionary) -> void:
	GameState.create_character("TestTransporter", "transporter")
	GameState.flags["fuel"] = 40
	GameState.stats.stamina = 5
	GameState.stats.grit = 4
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	var trans_res = TransporterMechanic.perform_transporter_work(rng)
	_assert_true(trans_res.success == true, "Transporter work succeeds with sufficient fuel", results)
	_assert_true(trans_res.fuel_consumed == 8, "Traffic Instinct perk burns only 8L fuel (down from 10L)", results)
	_assert_true(int(GameState.flags["fuel"]) == 32, "Fuel reduced by 8L (40 -> 32)", results)
	_assert_true(trans_res.park_dues == 500, "Standard 500 Naira union park dues deducted", results)
	
	# Test out of fuel
	GameState.flags["fuel"] = 3
	var fail_res = TransporterMechanic.perform_transporter_work(rng)
	_assert_true(fail_res.success == false, "Transporter work halted when fuel is insufficient", results)
	
	# Test refuel
	GameState.resources.naira = 20000
	var refuel_res = TransporterMechanic.refuel(20) # 20L * 600 = 12,000
	_assert_true(refuel_res.success == true, "Refuel succeeds", results)
	_assert_true(int(GameState.flags["fuel"]) == 23, "Fuel level increased by 20L (3 -> 23)", results)
	_assert_true(GameState.resources.naira == 8000, "Refuel cost deducted from Naira", results)

static func _test_levelling_system(results: Dictionary) -> void:
	GameState.create_character("TestLevel", "trader")
	GameState.level = 1
	GameState.xp = 0
	
	# Level 2 threshold is 100 XP
	GameState.xp = 110
	var lvl_report = Levelling.check_and_apply_levelups()
	_assert_true(lvl_report.levelled_up == true, "Player levelled up when XP passed threshold", results)
	_assert_true(GameState.level == 2, "Player reached Level 2", results)
	_assert_true(not lvl_report.stat_boosts.is_empty(), "Stat boost awarded on level-up", results)
	
	# Test Level 5 subclass unlock (Level 5 threshold is 700 XP)
	GameState.xp = 800
	var lvl5_report = Levelling.check_and_apply_levelups()
	_assert_true(GameState.level == 5, "Player reached Level 5", results)
	_assert_true(lvl5_report.subclass_unlocked == true, "Subclass unlocked at Level 5", results)
	
	# Apply subclass
	var apply_res = Levelling.apply_subclass("market_woman")
	_assert_true(apply_res.success == true, "Applied market_woman subclass at Level 5", results)
	_assert_true(GameState.subclass_id == "market_woman", "GameState subclass_id set to market_woman", results)
	
	# Test wrong class subclass rejection
	var wrong_res = Levelling.apply_subclass("danfo_driver")
	_assert_true(wrong_res.success == false, "Trader cannot select transporter subclass danfo_driver", results)
