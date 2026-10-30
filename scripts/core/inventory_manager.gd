class_name InventoryManager
extends RefCounted

## InventoryManager
## Manages the player's item inventory (add, remove, count, use consumables).
## Items are stored in GameState.inventory as an Array of { id, quantity } dicts.
## Pure core logic with zero UI code.

## Adds quantity of an item to inventory. Creates entry if not present.
static func add_item(item_id: String, quantity: int = 1) -> void:
	for entry in GameState.inventory:
		if entry.get("id", "") == item_id:
			entry["quantity"] = int(entry.get("quantity", 0)) + quantity
			return
	GameState.inventory.append({ "id": item_id, "quantity": quantity })

## Removes quantity of an item. Returns true if successful, false if insufficient.
static func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(GameState.inventory.size()):
		if GameState.inventory[i].get("id", "") == item_id:
			var current = int(GameState.inventory[i].get("quantity", 0))
			if current < quantity:
				return false
			GameState.inventory[i]["quantity"] = current - quantity
			if GameState.inventory[i]["quantity"] <= 0:
				GameState.inventory.remove_at(i)
			return true
	return false

## Returns the quantity of an item in inventory.
static func get_item_count(item_id: String) -> int:
	for entry in GameState.inventory:
		if entry.get("id", "") == item_id:
			return int(entry.get("quantity", 0))
	return 0

## Returns true if the player has at least `quantity` of the item.
static func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity

## Returns the total number of distinct item types in inventory.
static func get_distinct_item_count() -> int:
	return GameState.inventory.size()

## Returns the total weight of all items in inventory.
static func get_total_weight() -> int:
	var total = 0
	for entry in GameState.inventory:
		var item_data = DataLoader.get_item_by_id(entry.get("id", ""))
		var weight = int(item_data.get("weight", 1))
		total += weight * int(entry.get("quantity", 0))
	return total

## Maximum carry weight (can be modified by perks later).
static func get_max_weight() -> int:
	var base = 20
	# Transporter gets extra carry capacity
	if GameState.class_id == "transporter":
		base = 30
	return base

## Uses a consumable item, applying its effects. Returns result dictionary.
static func use_consumable(item_id: String) -> Dictionary:
	var item_data = DataLoader.get_item_by_id(item_id)
	if item_data.is_empty():
		return { "success": false, "message": "Unknown item." }
	
	if item_data.get("type", "") != "consumable":
		return { "success": false, "message": "This item cannot be consumed." }
	
	if not has_item(item_id):
		return { "success": false, "message": "You don't have this item." }
	
	var effects = item_data.get("effect", {})
	if effects.has("energy"):
		GameState.modify_resource("energy", int(effects["energy"]))
	if effects.has("respect"):
		GameState.modify_resource("respect", int(effects["respect"]))
	if effects.has("naira"):
		GameState.modify_resource("naira", int(effects["naira"]))
	if effects.has("heat"):
		GameState.modify_resource("heat", int(effects["heat"]))
	
	remove_item(item_id, 1)
	
	return {
		"success": true,
		"item_name": item_data.get("name", "Item"),
		"effects": effects,
		"message": "Used %s." % item_data.get("name", "item")
	}
