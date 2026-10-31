class_name ActivityManager
extends RefCounted

## ActivityManager
## Executes player activities (Work, Rest, Travel, Socialise), deducting costs,
## granting rewards, advancing time blocks, and checking for random street events.
## Decoupled core logic with zero UI references.

const TimeManager = preload("res://scripts/core/time_manager.gd")
const EventManager = preload("res://scripts/core/event_manager.gd")
const TraderMechanic = preload("res://scripts/core/trader_mechanic.gd")
const TransporterMechanic = preload("res://scripts/core/transporter_mechanic.gd")
const Levelling = preload("res://scripts/core/levelling.gd")
const WorkingClassMechanic = preload("res://scripts/core/workingclass_mechanic.gd")
const RoadOfficialMechanic = preload("res://scripts/core/roadofficial_mechanic.gd")

## Performs class-specific work/hustle
static func perform_work(rng: RandomNumberGenerator = null) -> Dictionary:
	var costs = DataLoader.get_activity_costs()
	var energy_cost = int(costs.get("work_energy", 20))
	
	if GameState.resources.energy < 10:
		return {
			"success": false,
			"message": "Too exhausted to work! You need at least 10 Energy. Rest first."
		}
	
	var income = 0
	var work_msg = ""
	var xp_gain = int(costs.get("work_xp", 15))
	
	# Class signature mechanics
	if GameState.class_id == "trader":
		var trader_res = TraderMechanic.perform_trader_work(rng)
		income = trader_res.income
		work_msg = trader_res.flavour
	elif GameState.class_id == "transporter":
		var trans_res = TransporterMechanic.perform_transporter_work(rng)
		if not trans_res.get("success", false):
			return {
				"success": false,
				"message": trans_res.get("message", "Cannot drive route.")
			}
		income = trans_res.income
		work_msg = trans_res.flavour
		xp_gain = trans_res.get("xp_gain", xp_gain)
	elif GameState.class_id == "area_boy":
		var ab_res = AreaBoyMechanic.perform_areaboy_work(rng)
		income = ab_res.income
		work_msg = ab_res.flavour
	elif GameState.class_id == "working_class":
		var wc_res = WorkingClassMechanic.perform_workingclass_work(rng)
		income = wc_res.income
		work_msg = wc_res.flavour
		if wc_res.get("energy_discount", false):
			energy_cost = wc_res.energy_cost
	elif GameState.class_id == "road_official":
		var ro_res = RoadOfficialMechanic.perform_roadofficial_work(rng)
		income = ro_res.income
		work_msg = ro_res.flavour
	else:
		income = DataLoader.get_work_income(GameState.class_id)
		work_msg = "You completed your work shift in Oshodi"
	
	# Respect Reputation bonus (+10% if Respect >= 20)
	var respect_bonus = false
	if GameState.resources.respect >= 20:
		income = int(income * 1.10)
		respect_bonus = true
	
	# Apply work effort and rewards
	GameState.modify_resource("energy", -energy_cost)
	GameState.modify_resource("naira", income)
	GameState.xp += xp_gain
	
	# Level up check
	var levelup_report = Levelling.check_and_apply_levelups()
	
	# High Heat consequence check (Heat >= 5 draws taskforce scrutiny)
	var heat_penalty_triggered = false
	if GameState.resources.heat >= 5:
		var heat_roll = rng.randf() if rng != null else randf()
		if heat_roll < 0.40:
			var fine = mini(GameState.resources.naira, 800)
			GameState.modify_resource("naira", -fine)
			GameState.modify_resource("heat", -2)
			heat_penalty_triggered = true
			work_msg += " (Task force patrol spotted you! Paid %s spot fine, Heat cooled by -2)." % GameState.format_naira(fine)
	
	var time_report = TimeManager.advance_time(1, rng)
	var event_result = EventManager.maybe_trigger_event(GameState.time_block, GameState.location_id, 0.65, rng)
	
	var full_msg = "%s! Earned %s and +%d XP (-%d Energy)." % [
		work_msg, GameState.format_naira(income), xp_gain, energy_cost
	]
	if respect_bonus:
		full_msg += " High Respect gave +10% bonus!"
	if levelup_report.get("levelled_up", false):
		full_msg += " [LEVEL UP] Reached Level %d!" % levelup_report.get("new_level", GameState.level)
	
	return {
		"success": true,
		"activity": "work",
		"income": income,
		"energy_spent": energy_cost,
		"xp_gained": xp_gain,
		"levelup_report": levelup_report,
		"heat_penalty_triggered": heat_penalty_triggered,
		"time_report": time_report,
		"event_result": event_result,
		"message": full_msg
	}

## Performs rest and recovery
static func perform_rest(rng: RandomNumberGenerator = null) -> Dictionary:
	var costs = DataLoader.get_activity_costs()
	var energy_gain = int(costs.get("rest_energy_gain", 35))
	
	var old_energy = GameState.resources.energy
	GameState.modify_resource("energy", energy_gain)
	var actual_gain = GameState.resources.energy - old_energy
	
	var time_report = TimeManager.advance_time(1, rng)
	var event_result = EventManager.maybe_trigger_event(GameState.time_block, GameState.location_id, 0.40, rng)
	
	return {
		"success": true,
		"activity": "rest",
		"energy_restored": actual_gain,
		"time_report": time_report,
		"event_result": event_result,
		"message": "You rested in the shade, recovering +%d Energy." % actual_gain
	}

## Commutes to another connected location
static func perform_travel(destination_id: String, rng: RandomNumberGenerator = null) -> Dictionary:
	var current_loc = DataLoader.get_location_by_id(GameState.location_id)
	var dest_loc = DataLoader.get_location_by_id(destination_id)
	
	if dest_loc.is_empty():
		return { "success": false, "message": "Unknown destination location." }
	
	# Find route from current location
	var travel_routes = current_loc.get("travel", [])
	var chosen_route: Dictionary = {}
	for r in travel_routes:
		if r.get("to", "") == destination_id:
			chosen_route = r
			break
	
	if chosen_route.is_empty():
		return { "success": false, "message": "No direct transport route to that location." }
	
	var fare = int(chosen_route.get("cost_naira", 200))
	if GameState.resources.naira < fare:
		return {
			"success": false,
			"message": "Not enough transport fare! You need %s to board this route." % GameState.format_naira(fare)
		}
	
	# Pay fare & update location
	GameState.modify_resource("naira", -fare)
	var old_loc_name = current_loc.get("name", "Oshodi")
	GameState.location_id = destination_id
	EventBus.location_changed.emit(destination_id)
	
	var blocks_spent = int(chosen_route.get("time_blocks", 1))
	var time_report = TimeManager.advance_time(blocks_spent, rng)
	var event_result = EventManager.maybe_trigger_event(GameState.time_block, destination_id, 0.50, rng)
	
	return {
		"success": true,
		"activity": "travel",
		"fare_paid": fare,
		"destination": dest_loc.get("name", destination_id),
		"time_report": time_report,
		"event_result": event_result,
		"message": "Boarded a transit ride from %s to %s for %s." % [
			old_loc_name, dest_loc.get("name", ""), GameState.format_naira(fare)
		]
	}

## Socialises with locals and traders
static func perform_socialise(rng: RandomNumberGenerator = null) -> Dictionary:
	var costs = DataLoader.get_activity_costs()
	var fee = int(costs.get("socialise_naira", 500))
	
	if GameState.resources.naira < fee:
		return {
			"success": false,
			"message": "Need at least %s to buy soft drinks or join the street banter." % GameState.format_naira(fee)
		}
	
	GameState.modify_resource("naira", -fee)
	var energy_gain = int(costs.get("socialise_energy_gain", 10))
	GameState.modify_resource("energy", energy_gain)
	var respect_gain = int(costs.get("socialise_respect", 2))
	GameState.modify_resource("respect", respect_gain)
	var xp_gain = int(costs.get("socialise_xp", 8))
	GameState.xp += xp_gain
	var levelup_report = Levelling.check_and_apply_levelups()
	
	# Chance to cool down street heat
	var heat_reduced = false
	var heat_roll = rng.randf() if rng else randf()
	if heat_roll > 0.5 and GameState.resources.heat > 0:
		GameState.modify_resource("heat", -1)
		heat_reduced = true
	
	var time_report = TimeManager.advance_time(1, rng)
	var event_result = EventManager.maybe_trigger_event(GameState.time_block, GameState.location_id, 0.40, rng)
	
	var msg = "Enjoyed pleasant banter with locals! +%d Respect, +%d XP, +%d Energy (-%s)." % [
		respect_gain, xp_gain, energy_gain, GameState.format_naira(fee)
	]
	if heat_reduced:
		msg += " Good word from neighbours cooled down Heat by -1!"
	if levelup_report.get("levelled_up", false):
		msg += " [LEVEL UP] Reached Level %d!" % levelup_report.get("new_level", GameState.level)
	
	return {
		"success": true,
		"activity": "socialise",
		"fee_paid": fee,
		"respect_gained": respect_gain,
		"heat_reduced": heat_reduced,
		"levelup_report": levelup_report,
		"time_report": time_report,
		"event_result": event_result,
		"message": msg
	}

## Checks if a situation conflict is triggered during daily street hustle
static func maybe_trigger_situation(trigger_chance: float = 0.25, rng: RandomNumberGenerator = null) -> Dictionary:
	var roll = rng.randf() if rng != null else randf()
	if roll < trigger_chance:
		var eligible = DataLoader.get_eligible_situations(GameState.class_id, GameState.location_id, GameState.time_block)
		if not eligible.is_empty():
			var idx = (rng.randi() % eligible.size()) if rng != null else (randi() % eligible.size())
			return {
				"triggered": true,
				"situation": eligible[idx]
			}
	return { "triggered": false, "situation": {} }
