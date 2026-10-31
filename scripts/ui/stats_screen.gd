extends Control

## StatsScreen
## Displays the active character's stats, resources, daily status, and class perks.

@onready var char_name_label: Label = %CharNameLabel
@onready var class_title_label: Label = %ClassTitleLabel
@onready var level_xp_label: Label = %LevelXpLabel
@onready var location_time_label: Label = %LocationTimeLabel

# Resource Labels
@onready var energy_val_label: Label = %EnergyValLabel
@onready var naira_val_label: Label = %NairaValLabel
@onready var respect_val_label: Label = %RespectValLabel
@onready var heat_val_label: Label = %HeatValLabel

# Stat Labels
@onready var hustle_label: Label = %HustleLabel
@onready var smarts_label: Label = %SmartsLabel
@onready var charisma_label: Label = %CharismaLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var grit_label: Label = %GritLabel

# Perks Labels
@onready var mechanic_label: Label = %MechanicLabel
@onready var perk_label: Label = %PerkLabel

# Buttons & Dialog
@onready var menu_button: Button = %MenuButton
@onready var enter_hub_button: Button = %EnterHubButton
@onready var info_dialog: AcceptDialog = %InfoDialog

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	enter_hub_button.pressed.connect(_on_enter_hub_pressed)
	
	_render_character_data()

func _render_character_data() -> void:
	var c_data = GameState.get_class_data()
	
	char_name_label.text = GameState.player_name.to_upper()
	class_title_label.text = c_data.get("name", "Unknown Class")
	level_xp_label.text = "Level %d • %d XP" % [GameState.level, GameState.xp]
	location_time_label.text = "Oshodi Market • Day %d (%s)" % [GameState.day, GameState.time_block.capitalize()]
	
	# Resources
	energy_val_label.text = "%d / %d" % [GameState.resources.energy, GameState.resources.max_energy]
	naira_val_label.text = GameState.format_naira(GameState.resources.naira)
	respect_val_label.text = str(GameState.resources.respect)
	heat_val_label.text = str(GameState.resources.heat)
	
	# Stats
	hustle_label.text = str(GameState.stats.hustle)
	smarts_label.text = str(GameState.stats.street_smarts)
	charisma_label.text = str(GameState.stats.charisma)
	stamina_label.text = str(GameState.stats.stamina)
	grit_label.text = str(GameState.stats.grit)
	
	# Mechanics & Perks
	var mechanic_name = c_data.get("signature_mechanic_name", c_data.get("signature_mechanic", "").capitalize())
	var mechanic_desc = c_data.get("signature_mechanic_desc", "")
	mechanic_label.text = "%s: %s" % [mechanic_name, mechanic_desc]
	
	var perk = c_data.get("passive_perk", {})
	var perk_name = perk.get("name", perk.get("id", "").capitalize())
	var perk_desc = perk.get("text", "")
	perk_label.text = "%s: %s" % [perk_name, perk_desc]

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_enter_hub_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
