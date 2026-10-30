class_name ShopManager
extends RefCounted

## ShopManager
## Handles buying and selling items at location shops.
## Prices come from items.json. Trader class gets margin bonuses.
## Pure core logic with zero UI code.

const InventoryManager = preload("res://scripts/core/inventory_manager.gd")

## Returns items available for purchase at the current location.
static func get_shop_inventory(location_id: String) -> Array[Dictionary]:
	var all_items = DataLoader.get_all_items()
	var available: Array[Dictionary] = []
	for item in all_items:
		var locs = item.get("available_at", [])
		if not locs.has(location_id):
			continue
		var class_req = item.get("class_req", null)
		if class_req != null and class_req != GameState.class_id:
			continue
		available.append(item)
	return available

## Buys an item from the shop. Returns result dictionary.
static func buy_item(item_id: String, quantity: int = 1) -> Dictionary:
	var item_data = DataLoader.get_item_by_id(item_id)
	if item_data.is_empty():
		return { "success": false, "message": "Unknown item." }
	
	var unit_price = int(item_data.get("buy_price", 0))
	var total_cost = unit_price * quantity
	
	if GameState.resources.naira < total_cost:
		return {
			"success": false,
			"message": "Not enough Naira! You need %s but only have %s." % [
				GameState.format_naira(total_cost),
				GameState.format_naira(GameState.resources.naira)
			]
		}
	
	# Check weight limit
	var item_weight = int(item_data.get("weight", 1)) * quantity
	var current_weight = InventoryManager.get_total_weight()
	var max_weight = InventoryManager.get_max_weight()
	if current_weight + item_weight > max_weight:
		return {
			"success": false,
			"message": "Too heavy! Carrying %d/%d kg. This item weighs %d kg." % [
				current_weight, max_weight, item_weight
			]
		}
	
	GameState.modify_resource("naira", -total_cost)
	InventoryManager.add_item(item_id, quantity)
	
	# Apply immediate effects for accessories
	if item_data.get("type", "") == "accessory":
		var effects = item_data.get("effect", {})
		for stat_key in effects:
			if GameState.stats.has(stat_key):
				GameState.modify_stat(stat_key, int(effects[stat_key]))
	
	return {
		"success": true,
		"item_name": item_data.get("name", "Item"),
		"quantity": quantity,
		"total_cost": total_cost,
		"message": "Bought %dx %s for %s." % [
			quantity, item_data.get("name", ""), GameState.format_naira(total_cost)
		]
	}

## Sells an item from inventory. Trader class gets better sell margins.
static func sell_item(item_id: String, quantity: int = 1) -> Dictionary:
	var item_data = DataLoader.get_item_by_id(item_id)
	if item_data.is_empty():
		return { "success": false, "message": "Unknown item." }
	
	if not InventoryManager.has_item(item_id, quantity):
		return { "success": false, "message": "You don't have enough of this item to sell." }
	
	var base_sell = int(item_data.get("sell_price", 0))
	var unit_price = base_sell
	
	# Trader class bonus: +15% sell margin
	if GameState.class_id == "trader":
		unit_price = int(base_sell * 1.15)
	
	# Subclass bonus for Market Woman: +5% on top
	if GameState.subclass_id == "market_woman":
		unit_price = int(unit_price * 1.05)
	
	var total_revenue = unit_price * quantity
	
	InventoryManager.remove_item(item_id, quantity)
	GameState.modify_resource("naira", total_revenue)
	
	var xp_gain = 5 * quantity
	GameState.xp += xp_gain
	
	return {
		"success": true,
		"item_name": item_data.get("name", "Item"),
		"quantity": quantity,
		"unit_price": unit_price,
		"total_revenue": total_revenue,
		"xp_gained": xp_gain,
		"message": "Sold %dx %s for %s (+%d XP)." % [
			quantity, item_data.get("name", ""), GameState.format_naira(total_revenue), xp_gain
		]
	}
