class_name TraderMechanic
extends RefCounted

## TraderMechanic
## Implements the Trader's "Stock & Price" signature mechanic.
## Traders buy stock wholesale, carry it, and sell at market prices.
## Market prices fluctuate each day based on location, demand, and random events.
## Pure core logic with zero UI code.

const InventoryManager = preload("res://scripts/core/inventory_manager.gd")

## Performs a Trader work shift: buy cheap stock, haul it, sell at market margins.
## Returns a detailed work report.
static func perform_trader_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var hustle = int(GameState.stats.get("hustle", 3))
	var charisma = int(GameState.stats.get("charisma", 3))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("trader")
	
	# Hustle bonus: +5% per hustle point above 3
	var hustle_bonus = maxf(0.0, (hustle - 3) * 0.05)
	
	# Good Eye perk: 20% chance to find a bargain stock deal (+30% bonus)
	var bargain_found = false
	if roll < 0.20:
		bargain_found = true
		hustle_bonus += 0.30
	
	# Charisma bonus: better haggling, +3% per charisma above 3
	var charisma_bonus = maxf(0.0, (charisma - 3) * 0.03)
	
	# Subclass bonuses
	var subclass_bonus = 0.0
	match GameState.subclass_id:
		"market_woman":
			subclass_bonus = 0.10 # +10% steady regular customer income
		"traffic_hawker":
			# Gridlock bonus: random chance at +25%
			var gridlock_roll = rng.randf() if rng != null else randf()
			if gridlock_roll < 0.30:
				subclass_bonus = 0.25
		"pure_water_seller":
			# Afternoon rush bonus
			if GameState.time_block == "afternoon":
				subclass_bonus = 0.20
		"phone_accessories_dealer":
			subclass_bonus = 0.08 # Steady electronics margin
		"foodstuff_wholesaler":
			subclass_bonus = 0.12 # Bulk wholesale margins
		"mama_put":
			subclass_bonus = 0.15 # Food service margins
	
	var total_multiplier = 1.0 + hustle_bonus + charisma_bonus + subclass_bonus
	var final_income = int(base_income * total_multiplier)
	
	# Build flavour text
	var work_flavour = "You hustled hard at your market stall"
	if bargain_found:
		work_flavour = "Your Good Eye spotted a wholesaler clearing stock cheap! You flipped it for fat margins"
	if GameState.subclass_id == "traffic_hawker" and subclass_bonus > 0:
		work_flavour = "A massive gridlock stalled traffic for an hour — you sold everything through the car windows"
	elif GameState.subclass_id == "pure_water_seller" and subclass_bonus > 0:
		work_flavour = "The blazing afternoon sun sent thirsty commuters rushing for your ice-cold sachets"
	
	return {
		"income": final_income,
		"bargain_found": bargain_found,
		"multiplier": total_multiplier,
		"flavour": work_flavour
	}
