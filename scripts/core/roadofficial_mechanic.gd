class_name RoadOfficialMechanic
extends RefCounted

## RoadOfficialMechanic
## Implements the Road Official signature mechanic: "Checkpoint Enforcement & Integrity".
## Models traffic enforcement, corridor management, road safety, and checkpoint operations.
## Balances regulatory authority, corridor order, and public Respect.
## Pure core logic with zero UI code.

## Performs a road enforcement shift along the Oshodi transit corridor.
## Returns a detailed report dictionary.
static func perform_roadofficial_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var charisma = int(GameState.stats.get("charisma", 5))
	var smarts = int(GameState.stats.get("street_smarts", 4))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("road_official")
	if base_income <= 0:
		base_income = 3000
	
	# Charisma bonus: commanding presence and clear instruction (+7% per point above 3)
	var charisma_bonus = maxf(0.0, (charisma - 3) * 0.07)
	
	# Street smarts bonus: spotting fraudulent papers and bad driving (+5% per point above 3)
	var smarts_bonus = maxf(0.0, (smarts - 3) * 0.05)
	
	# Subclass modifiers
	var subclass_bonus = 0.0
	var respect_gained = 1
	var heat_delta = 0
	var flavour = "You maintained corridor order along the transit expressway, keeping traffic moving."
	
	match GameState.subclass_id:
		"lastma_officer":
			subclass_bonus = 0.20 # Choke point decongestion
			flavour = "You directed traffic at the central junction, citing reckless lane blockages."
		"traffic_warden":
			subclass_bonus = 0.15 # Junction choreography
			respect_gained = 2 # Commuters appreciate rhythmic crossing control
			flavour = "You orchestrated the crossroad flows with rhythmic gestures, earning commuter waves."
		"police_checkpoint_officer":
			subclass_bonus = 0.25 # Corridor patrol
			heat_delta = -1 # Active patrols deter neighborhood street crime
			flavour = "You conducted vehicle security checks along the perimeter corridor, maintaining calm."
		"vehicle_inspector":
			subclass_bonus = 0.18 # Roadworthiness audits
			flavour = "You inspected commercial minibuses for tire tread and brake certificates."
		"tow_truck_operator":
			subclass_bonus = 0.30 # Heavy recovery logistics
			flavour = "You winched a broken-down articulated trailer off the expressway inner lane."
		"road_safety_volunteer":
			subclass_bonus = 0.10 # Civic marshal stipend
			respect_gained = 3 # High public esteem for voluntary service
			flavour = "You marshaled safe pedestrian crossings for school pupils and cautioned speeding drivers."
	
	# Passive perk check: official_command suppresses street disorder
	if GameState.has_perk("official_command") and heat_delta >= 0:
		heat_delta -= 1
	
	var total_multiplier = 1.0 + charisma_bonus + smarts_bonus + subclass_bonus
	var final_income = int(base_income * total_multiplier)
	
	if respect_gained > 0:
		GameState.modify_resource("respect", respect_gained)
	if heat_delta != 0:
		GameState.modify_resource("heat", heat_delta)
	
	return {
		"success": true,
		"income": final_income,
		"multiplier": total_multiplier,
		"respect_gained": respect_gained,
		"heat_delta": heat_delta,
		"flavour": flavour
	}

## Conducts an active roadside checkpoint stop on a commercial vehicle.
static func conduct_inspection_stop(rng: RandomNumberGenerator = null) -> Dictionary:
	if GameState.resources.energy < 15:
		return {
			"success": false,
			"message": "Too fatigued to stand post for a vehicle inspection. Need at least 15 Energy."
		}
	
	GameState.modify_resource("energy", -15)
	var smarts = int(GameState.stats.get("street_smarts", 4))
	var roll = rng.randf() if rng != null else randf()
	
	# 70% chance legitimate motorist with valid papers, 30% minor violation rectified
	var reward_naira = 1500
	var xp_gain = 20
	var respect_gain = 2
	
	if roll < 0.70:
		GameState.modify_resource("naira", reward_naira)
		GameState.modify_resource("respect", respect_gain)
		GameState.xp += xp_gain
		return {
			"success": true,
			"income": reward_naira,
			"xp": xp_gain,
			"respect": respect_gain,
			"message": "Vehicle papers verified cleanly. Motorist thanked you for courteous service (+%s, +%d Respect, +%d XP)." % [
				GameState.format_naira(reward_naira), respect_gain, xp_gain
			]
		}
	else:
		# Minor infringement resolved officially
		reward_naira = 2200
		respect_gain = 1
		GameState.modify_resource("naira", reward_naira)
		GameState.modify_resource("respect", respect_gain)
		GameState.xp += xp_gain
		return {
			"success": true,
			"income": reward_naira,
			"xp": xp_gain,
			"respect": respect_gain,
			"message": "Spotted a cracked brake lens. Issued official cautionary compliance ticket (+%s, +%d Respect, +%d XP)." % [
				GameState.format_naira(reward_naira), respect_gain, xp_gain
			]
		}
