class_name WorkingClassMechanic
extends RefCounted

## WorkingClassMechanic
## Implements the Working Class signature mechanic: "Overtime & Focus".
## Models salaried and skilled trades in Lagos (mechanics, technicians,
## factory staff, clerks, security, essential workers).
## Balances steady wages and overtime opportunities against physical fatigue.
## Pure core logic with zero UI code.

## Performs a standard working class shift.
## Grants steady base income, stamina/hustle bonuses, subclass perk benefits,
## and applies the steady_hands energy discount.
static func perform_workingclass_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var stamina = int(GameState.stats.get("stamina", 5))
	var hustle = int(GameState.stats.get("hustle", 4))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("working_class")
	if base_income <= 0:
		base_income = 3500
	
	# Stamina bonus: endurance through long shifts (+6% per point above 3)
	var stamina_bonus = maxf(0.0, (stamina - 3) * 0.06)
	
	# Hustle bonus: diligence and client rapport (+5% per point above 3)
	var hustle_bonus = maxf(0.0, (hustle - 3) * 0.05)
	
	# Subclass bonuses and flavour
	var subclass_bonus = 0.0
	var respect_gained = 1
	var flavour = "You completed an honest, productive shift in the district."
	
	match GameState.subclass_id:
		"mechanic":
			subclass_bonus = 0.20 # Engine diagnostics & repair bonus
			flavour = "You diagnosed and overhauled an alternator assembly along Bolade auto strip."
		"factory_hand":
			subclass_bonus = 0.25 # Quota achievement bonus
			flavour = "You hit your production packaging targets on the Isolo plant floor."
		"bank_clerk":
			subclass_bonus = 0.15 # Daily ledger balance accuracy
			flavour = "You balanced the branch cash ledgers cleanly without a single discrepancy."
		"security_guard":
			subclass_bonus = 0.12 # Perimeter vigilance hazard pay
			flavour = "You maintained tight perimeter vigilance at the corporate logistics gates."
		"generator_repairer":
			subclass_bonus = 0.30 # Blackout emergency dynamo service
			flavour = "You serviced commercial backup dynamos following an industrial blackout."
		"teacher_nurse":
			subclass_bonus = 0.18 # Evening tuition & community clinic service
			respect_gained = 2 # Community pillars earn higher respect
			flavour = "You attended to neighborhood patients and conducted private evening lessons."
	
	var total_multiplier = 1.0 + stamina_bonus + hustle_bonus + subclass_bonus
	var final_income = int(base_income * total_multiplier)
	
	# Steady Hands perk check: reduces energy cost from 20 to 16
	var energy_discount = GameState.has_perk("steady_hands")
	var energy_cost = 16 if energy_discount else 20
	
	GameState.modify_resource("respect", respect_gained)
	
	return {
		"success": true,
		"income": final_income,
		"multiplier": total_multiplier,
		"energy_cost": energy_cost,
		"energy_discount": energy_discount,
		"respect_gained": respect_gained,
		"flavour": flavour
	}

## Takes on an intensive overtime shift.
## Higher energy investment (30 or 25 with steady_hands) for 1.75x payout and +20 XP.
static func request_overtime(rng: RandomNumberGenerator = null) -> Dictionary:
	var energy_cost = 25 if GameState.has_perk("steady_hands") else 30
	if GameState.resources.energy < energy_cost:
		return {
			"success": false,
			"message": "Too fatigued for an overtime shift. Need at least %d Energy." % energy_cost
		}
	
	var base_work = perform_workingclass_work(rng)
	var overtime_income = int(base_work.income * 1.75)
	var xp_gain = 25
	
	GameState.modify_resource("energy", -energy_cost)
	GameState.modify_resource("naira", overtime_income)
	GameState.xp += xp_gain
	
	var overtime_msg = "Overtime shift completed! You put in late hours: earned %s and +%d XP (-%d Energy)." % [
		GameState.format_naira(overtime_income), xp_gain, energy_cost
	]
	
	return {
		"success": true,
		"income": overtime_income,
		"energy_spent": energy_cost,
		"xp_gain": xp_gain,
		"message": overtime_msg,
		"flavour": base_work.flavour
	}
