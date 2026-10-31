class_name FaithLeaderMechanic
extends RefCounted

## FaithLeaderMechanic
## Implements the Faith Leader signature mechanic: "Congregation Trust & Stewardship".
## Models spiritual leadership, community sanctuary, pastoral counseling, and welfare outreach.
## Portrayed with cultural dignity, warmth, and affectionate community reality.
## Pure core logic with zero UI code.

## Performs a congregation and pastoral service shift.
## Returns a detailed report dictionary.
static func perform_faithleader_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	var charisma = int(GameState.stats.get("charisma", 5))
	var smarts = int(GameState.stats.get("street_smarts", 4))
	
	# Base income from economy.json
	var base_income = DataLoader.get_work_income("faith_leader")
	if base_income <= 0:
		base_income = 2500
	
	# Charisma bonus: inspiring delivery and comforting warmth (+8% per point above 3)
	var charisma_bonus = maxf(0.0, (charisma - 3) * 0.08)
	
	# Street smarts bonus: understanding real family struggles (+5% per point above 3)
	var smarts_bonus = maxf(0.0, (smarts - 3) * 0.05)
	
	# Subclass modifiers
	var subclass_bonus = 0.0
	var respect_gained = 2
	var heat_delta = 0
	var xp_bonus = 0
	var flavour = "You led community sanctuary sessions, offering counsel, comfort, and prayers."
	
	match GameState.subclass_id:
		"pastor":
			subclass_bonus = 0.20 # Pastoral benevolence
			respect_gained = 3
			flavour = "You delivered an inspiring message of hope and counseled struggling families."
		"imam":
			subclass_bonus = 0.15 # Community zakat stewardship
			respect_gained = 3
			heat_delta = -1 # Friday harmony sermon cools street tensions
			flavour = "You delivered a moving Jum'ah sermon on neighbourliness and oversaw charity distribution."
		"prophet_prayer_warrior":
			subclass_bonus = 0.25 # Vigil endurance
			xp_bonus = 5
			flavour = "You sustained community spirits through an uplifting midnight intercession vigil."
		"evangelist":
			subclass_bonus = 0.10 # Modest commuter tokens
			flavour = "You shared words of encouragement and patience with weary morning bus commuters."
		"usher_choirmaster":
			subclass_bonus = 0.18 # Sanctuary music and logistics
			flavour = "You directed the youth choir rehearsals, filling the sanctuary with vibrant melodies."
		"traditional_priest":
			subclass_bonus = 0.20 # Customary consultation
			flavour = "You mediated an ancestral property dispute using time-honored community proverbs."
	
	# Passive perk check: blessed_words boosts community respect
	if GameState.has_perk("blessed_words"):
		respect_gained += 1
	
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
		"xp_bonus": xp_bonus,
		"flavour": flavour
	}

## Organizes a community welfare outreach or food distribution drive.
static func organize_community_outreach(rng: RandomNumberGenerator = null) -> Dictionary:
	if GameState.resources.energy < 15:
		return {
			"success": false,
			"message": "Too exhausted to coordinate community outreach today. Need at least 15 Energy."
		}
	
	var benevolence_cost = 1000
	if GameState.resources.naira < benevolence_cost:
		return {
			"success": false,
			"message": "Need at least %s in benevolence funds to distribute welfare packages." % GameState.format_naira(benevolence_cost)
		}
	
	GameState.modify_resource("energy", -15)
	GameState.modify_resource("naira", -benevolence_cost)
	
	var respect_gain = 4
	var heat_reduction = mini(GameState.resources.heat, 2)
	var xp_gain = 25
	
	GameState.modify_resource("respect", respect_gain)
	if heat_reduction > 0:
		GameState.modify_resource("heat", -heat_reduction)
	GameState.xp += xp_gain
	
	var msg = "Welfare outreach successful! You provided food parcels to vulnerable neighbours (+%d Respect, Heat -%d, +%d XP)." % [
		respect_gain, heat_reduction, xp_gain
	]
	
	return {
		"success": true,
		"respect_gained": respect_gain,
		"heat_reduced": heat_reduction,
		"xp_gained": xp_gain,
		"message": msg
	}
