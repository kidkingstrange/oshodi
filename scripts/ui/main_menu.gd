extends Control

## MainMenu
## Main menu controller for Oshodimushin RPG.
## Handles navigation to Character Creation, Settings, and Game Exit.

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var test_button: Button = %TestButton
@onready var style_guide_button: Button = %StyleGuideButton
@onready var status_label: Label = %StatusLabel
@onready var info_dialog: AcceptDialog = %InfoDialog

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if test_button:
		test_button.pressed.connect(_on_test_pressed)
	if style_guide_button:
		style_guide_button.pressed.connect(_on_style_guide_pressed)
	
	if status_label:
		status_label.text = "Select 'Start Game' to play, or 'Run Tests' to verify logic."
	
	if GameState.has_character():
		play_button.text = "Continue Game (%s - Day %d)" % [GameState.player_name, GameState.day]
	else:
		play_button.text = "Start Game"

func _on_play_pressed() -> void:
	if GameState.has_character():
		print("[MainMenu] Continuing game to Hub.")
		get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
	else:
		print("[MainMenu] Starting character creation.")
		get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_test_pressed() -> void:
	print("[MainMenu] Opening test runner.")
	get_tree().change_scene_to_file("res://tests/test_runner.tscn")

func _on_settings_pressed() -> void:
	print("[MainMenu] Settings pressed.")
	if status_label:
		status_label.text = "Settings panel will be implemented in Phase 5."
	if info_dialog:
		info_dialog.title = "Settings"
		info_dialog.dialog_text = "The Settings panel (audio, text size, save management) will be built in Phase 5 per docs/04_ROADMAP.md."
		info_dialog.popup_centered()

func _on_quit_pressed() -> void:
	print("[MainMenu] Quit pressed.")
	get_tree().quit()

func _on_style_guide_pressed() -> void:
	print("[MainMenu] Opening Danfo Poster style guide.")
	get_tree().change_scene_to_file("res://scenes/style_guide.tscn")

