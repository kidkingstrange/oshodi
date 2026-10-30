class_name TransporterMechanic
extends RefCounted

## TransporterMechanic
## Implements the Transporter's "Route & Momentum" signature mechanic.
## Transporters run bus/keke routes, manage fuel, handle passenger mood,
## and pay motor park union dues.
## Pure core logic with zero UI code.

## Performs a Transporter work shift: run a route, collect fares, burn fuel.
## Returns a detailed work report.
static func perform_transporter_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var stamina = int(GameState.stats.get("stamina", 3))
	var grit = int(GameState.stats.get("grit", 3))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("transporter")
	
	# Fuel consumption: base 10 per shift, reduced by Traffic Instinct perk
	var fuel_cost = 10
	var has_traffic_instinct = true # All transporters have this perk
	if has_traffic_instinct:
		fuel_cost = 8
	
	# Check if player has enough fuel
	var current_fuel = int(GameState.flags.get("fuel", 50))
	if current_fuel < fuel_cost:
		return {
			"success": false,
			"income": 0,
			"message": "Not enough fuel to run a route! Buy fuel at a filling station or use a Fuel Voucher.",
			"fuel_remaining": current_fuel
		}
	
	# Burn fuel
	GameState.flags["fuel"] = current_fuel - fuel_cost
	
	# Passenger mood affects tips: random factor + charisma
	var mood_roll = rng.randf() if rng != null else randf()
	var passenger_mood = "neutral"
	var tip_multiplier = 1.0
	
	if mood_roll > 0.75:
		passenger_mood = "happy"
		tip_multiplier = 1.20
	elif mood_roll < 0.15:
		passenger_mood = "angry"
		tip_multiplier = 0.85
	
	# Stamina bonus: +4% per stamina above 3 (endurance for long routes)
	var stamina_bonus = maxf(0.0, (stamina - 3) * 0.04)
	
	# Grit bonus: +3% per grit above 3 (handling tough traffic)
	var grit_bonus = maxf(0.0, (grit - 3) * 0.03)
	
	# Park dues: union levy per shift (fixed cost)
	var park_dues = 500
	
	# Subclass bonuses
	var subclass_bonus = 0.0
	var subclass_flavour = ""
	match GameState.subclass_id:
		"danfo_driver":
			subclass_bonus = 0.10
			subclass_flavour = "Your danfo packed to capacity along the expressway"
		"keke_rider":
			subclass_bonus = 0.05
			fuel_cost = maxi(fuel_cost - 3, 2) # Keke uses less fuel
			subclass_flavour = "Your keke weaved nimbly through the side streets"
		"okada_dispatch":
			subclass_bonus = 0.08
			subclass_flavour = "You completed two urgent dispatch deliveries back-to-back"
		"bus_conductor":
			subclass_bonus = 0.12
			subclass_flavour = "You filled the bus to bursting and collected every last fare"
		"airport_shuttle":
			subclass_bonus = 0.18
			park_dues = 800 # Higher union dues for premium routes
			subclass_flavour = "Your airport shuttle carried executives at premium fares"
		"long_distance":
			subclass_bonus = 0.15
			fuel_cost += 5
			park_dues = 700
			subclass_flavour = "You completed a long-haul route to the next state"
	
	var total_multiplier = tip_multiplier + stamina_bonus + grit_bonus + subclass_bonus
	var gross_income = int(base_income * total_multiplier)
	var net_income = maxi(0, gross_income - park_dues)
	
	# Apply income
	var xp_gain = 15
	
	# Flavour text
	var mood_text = ""
	match passenger_mood:
		"happy":
			mood_text = "Passengers were cheerful and tipped generously!"
		"angry":
			mood_text = "Commuters complained about the bumpy ride and slow pace."
		_:
			mood_text = "A routine trip with the usual Oshodi hustle."
	
	var flavour = subclass_flavour if not subclass_flavour.is_empty() else "You drove your route through the Oshodi corridors"
	
	return {
		"success": true,
		"income": net_income,
		"gross_income": gross_income,
		"park_dues": park_dues,
		"fuel_consumed": fuel_cost,
		"fuel_remaining": int(GameState.flags.get("fuel", 50)) ,
		"passenger_mood": passenger_mood,
		"tip_multiplier": tip_multiplier,
		"multiplier": total_multiplier,
		"xp_gain": xp_gain,
		"flavour": "%s. %s" % [flavour, mood_text],
		"message": "%s. Earned %s (gross %s minus %s park dues). Fuel: %d remaining. %s" % [
			flavour,
			GameState.format_naira(net_income),
			GameState.format_naira(gross_income),
			GameState.format_naira(park_dues),
			int(GameState.flags.get("fuel", 50)),
			mood_text
		]
	}

## Refuels the vehicle. Can use fuel voucher item or buy fuel with Naira.
static func refuel(litres: int = 20) -> Dictionary:
	var cost_per_litre = 600 # Current Lagos fuel price (fictional)
	var total_cost = cost_per_litre * litres
	
	if GameState.resources.naira < total_cost:
		return {
			"success": false,
			"message": "Not enough Naira for fuel! Need %s." % GameState.format_naira(total_cost)
		}
	
	GameState.modify_resource("naira", -total_cost)
	var old_fuel = int(GameState.flags.get("fuel", 0))
	var new_fuel = mini(old_fuel + litres, 100) # Max fuel tank: 100
	GameState.flags["fuel"] = new_fuel
	var actual_added = new_fuel - old_fuel
	
	return {
		"success": true,
		"litres_added": actual_added,
		"fuel_level": new_fuel,
		"cost": total_cost,
		"message": "Refuelled +%d litres for %s. Tank: %d/100." % [
			actual_added, GameState.format_naira(total_cost), new_fuel
		]
	}
