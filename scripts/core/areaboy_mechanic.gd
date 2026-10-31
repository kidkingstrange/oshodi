class_name AreaBoyMechanic
extends RefCounted

## AreaBoyMechanic
## Implements the Area Boy signature mechanic: "Turf Influence & Levies".
## Controls street territory, collects park and loading levies,
## balances dominance with rising law enforcement Heat.
## Pure core logic with zero UI code.

## Performs an Area Boy work shift: patrol territory and collect levies.
## Returns a detailed report dictionary.
static func perform_areaboy_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var grit = int(GameState.stats.get("grit", 3))
	var smarts = int(GameState.stats.get("street_smarts", 3))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("area_boy")
	if base_income <= 0:
		base_income = 2200
	
	# Grit bonus: muscle and authority (+8% per point above 3)
	var grit_bonus = maxf(0.0, (grit - 3) * 0.08)
	
	# Street smarts bonus: spot high-yield collection points (+5% per point above 3)
	var smarts_bonus = maxf(0.0, (smarts - 3) * 0.05)
	
	# Subclass modifiers
	var subclass_bonus = 0.0
	var heat_generated = 1
	var respect_generated = 1
	var flavour = "You controlled your turf under Oshodi bridge, collecting standard loading dues."
	
	match GameState.subclass_id:
		"agbero":
			subclass_bonus = 0.25 # +25% bay command
			flavour = "You commanded the danfo loading bays with your whistle, collecting brisk union levies."
		"vigilante":
			subclass_bonus = 0.15 # Community guard stipend
			heat_generated = 0 # Guards reduce street disorder
			respect_generated = 2
			flavour = "You patrolled the residential gates and night compound, earning community security dues."
		"one_chance_operator":
			subclass_bonus = 0.45 # High reward illicit con
			heat_generated = 3 # Severe heat accumulation
			respect_generated = -1
			flavour = "You ran a high-stakes passenger scam along the expressway corridor, grabbing fat cash but sparking panic."
		"landlords_enforcer":
			subclass_bonus = 0.20 # Rent arrears recovery
			flavour = "You enforced tenement arrears for Baba Landlord, securing overdue rent payments."
		"pickpocket":
			subclass_bonus = 0.15 # Crowd slip
			heat_generated = 2
			flavour = "You slipped through dense pedestrian bridge bottlenecks, snatching loose coins and notes."
		"politicians_youth_wing":
			subclass_bonus = 0.35 # Party mobilization allowance
			heat_generated = 1
			flavour = "You mobilized the grassroots youth wing for a political rally, distributing campaign allowances."
	
	# Passive perk check: street_respect gives extra Respect
	if GameState.has_perk("street_respect"):
		respect_generated += 1
	
	var total_multiplier = 1.0 + grit_bonus + smarts_bonus + subclass_bonus
	var final_income = int(base_income * total_multiplier)
	
	# Apply class-specific heat and respect deltas directly
	if heat_generated != 0:
		GameState.modify_resource("heat", heat_generated)
	if respect_generated != 0:
		GameState.modify_resource("respect", respect_generated)
	
	return {
		"success": true,
		"income": final_income,
		"multiplier": total_multiplier,
		"heat_gained": heat_generated,
		"respect_gained": respect_generated,
		"flavour": flavour
	}

## Spends energy to keep a low profile in compound alleys, reducing Heat.
static func lay_low() -> Dictionary:
	if GameState.resources.energy < 10:
		return {
			"success": false,
			"message": "Too exhausted to lay low safely. Need at least 10 Energy."
		}
	
	GameState.modify_resource("energy", -10)
	var current_heat = GameState.resources.heat
	var heat_reduction = mini(current_heat, 3)
	GameState.modify_resource("heat", -heat_reduction)
	
	return {
		"success": true,
		"heat_reduced": heat_reduction,
		"message": "You stayed out of sight behind the market stalls. Heat reduced by %d." % heat_reduction
	}
