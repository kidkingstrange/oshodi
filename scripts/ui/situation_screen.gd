extends Control

## SituationScreen
## UI controller for Situations (the conflict system).
## Displays situation setup, option choices with stat check indicators,
## computes outcomes via SituationResolver, and displays animated results & effect pills.

const SituationResolver = preload("res://scripts/core/situation_resolver.gd")

@onready var title_label: Label = %TitleLabel
@onready var location_badge_label: Label = %LocationBadgeLabel
@onready var setup_text_label: Label = %SetupTextLabel

# Choices & Resolution Containers
@onready var options_vbox: VBoxContainer = %OptionsVBox
@onready var resolution_card: PanelContainer = %ResolutionCard
@onready var outcome_badge_label: Label = %OutcomeBadgeLabel
@onready var roll_breakdown_label: Label = %RollBreakdownLabel
@onready var result_text_label: Label = %ResultTextLabel
@onready var effects_pills_label: Label = %EffectsPillsLabel
@onready var exhaustion_alert_label: Label = %ExhaustionAlertLabel
@onready var continue_button: Button = %ContinueButton

var current_situation: Dictionary = {}

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	resolution_card.visible = false
	
	# Load current situation from GameState or pick eligible one
	var sit_id = GameState.flags.get("active_situation_id", "")
	if not sit_id.is_empty():
		current_situation = DataLoader.get_situation_by_id(sit_id)
	
	if current_situation.is_empty():
		# Fallback: pick an eligible situation
		var eligible = DataLoader.get_eligible_situations(GameState.class_id, GameState.location_id, GameState.time_block)
		if not eligible.is_empty():
			current_situation = eligible[0]
		else:
			current_situation = DataLoader.get_all_situations()[0]
	
	_render_situation()

func _render_situation() -> void:
	title_label.text = current_situation.get("title", "Street Situation").to_upper()
	var loc_tags = current_situation.get("location_tags", [])
	location_badge_label.text = "Location: " + (", ".join(loc_tags).replace("_", " ").capitalize() if not loc_tags.has("all") else "Anywhere in Oshodi")
	setup_text_label.text = current_situation.get("setup_text", "")
	
	# Clear existing option buttons
	for child in options_vbox.get_children():
		child.queue_free()
	
	var options = current_situation.get("options", [])
	for opt in options:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var check = opt.get("check", null)
		var check_tag = ""
		if check != null and check is Dictionary:
			var stat = check.get("stat", "").capitalize()
			var diff = check.get("difficulty", 5)
			var player_stat = GameState.stats.get(check.get("stat", ""), 1)
			check_tag = " [%s %d vs Diff %d]" % [stat, player_stat, diff]
		else:
			check_tag = " [Guaranteed Option]"
		
		btn.text = opt.get("label", "Choose Option") + check_tag
		var opt_id = opt.get("id", "")
		btn.pressed.connect(func(): _on_option_chosen(opt_id))
		options_vbox.add_child(btn)

func _on_option_chosen(option_id: String) -> void:
	# Disable option buttons to prevent double click
	for child in options_vbox.get_children():
		if child is Button:
			child.disabled = true
	
	var outcome = SituationResolver.resolve_option(current_situation, option_id)
	_display_outcome(outcome)

func _display_outcome(outcome: Dictionary) -> void:
	resolution_card.visible = true
	
	var is_success = outcome.get("is_success", true)
	if outcome.get("has_check", false):
		var stat_name = outcome.get("stat_name", "").capitalize()
		var stat_val = outcome.get("stat_val", 0)
		var roll = outcome.get("roll", 0)
		var total = outcome.get("total", 0)
		var diff = outcome.get("difficulty", 0)
		
		if is_success:
			outcome_badge_label.text = "SUCCESS"
			outcome_badge_label.add_theme_color_override("font_color", Color(0.12, 0.58, 0.28, 1))
		else:
			outcome_badge_label.text = "CHALLENGE FAILED"
			outcome_badge_label.add_theme_color_override("font_color", Color(0.85, 0.22, 0.22, 1))
		
		roll_breakdown_label.text = "Roll Breakdown: %s (%d) + Roll (%d) = %d vs Target Difficulty %d" % [
			stat_name, stat_val, roll, total, diff
		]
	else:
		outcome_badge_label.text = "RESOLVED"
		outcome_badge_label.add_theme_color_override("font_color", Color(0.1, 0.45, 0.75, 1))
		roll_breakdown_label.text = "No stat check required."
	
	result_text_label.text = outcome.get("result_text", "")
	
	# Build effects summary pills
	var effects = outcome.get("effects", {})
	var effect_strings: Array[String] = []
	if effects.has("naira"):
		var n = int(effects["naira"])
		effect_strings.append(("+%s" if n >= 0 else "%s") % GameState.format_naira(n))
	if effects.has("energy"):
		var e = int(effects["energy"])
		effect_strings.append(("%+d Energy" % e))
	if effects.has("respect"):
		var r = int(effects["respect"])
		effect_strings.append(("%+d Respect" % r))
	if effects.has("heat"):
		var h = int(effects["heat"])
		effect_strings.append(("%+d Heat" % h))
	if effects.has("xp"):
		var x = int(effects["xp"])
		effect_strings.append(("+%d XP" % x))
	
	if not effect_strings.is_empty():
		effects_pills_label.text = "Effects Applied: " + " • ".join(effect_strings)
		effects_pills_label.visible = true
	else:
		effects_pills_label.visible = false
	
	# Exhaustion alert
	if outcome.get("exhaustion_triggered", false):
		exhaustion_alert_label.text = outcome.get("exhaustion_message", "")
		exhaustion_alert_label.visible = true
	else:
		exhaustion_alert_label.visible = false

func _on_continue_pressed() -> void:
	GameState.flags.erase("active_situation_id")
	get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
