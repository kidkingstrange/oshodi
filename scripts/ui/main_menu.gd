extends Control

## MainMenu
## Main menu controller for Oshodimushin RPG.
## Handles navigation to Character Creation, Settings, and Game Exit.

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	if status_label:
		status_label.text = "Phase 0 Setup: Project Ready. Select an option."

func _on_play_pressed() -> void:
	print("[MainMenu] Play pressed.")
	if status_label:
		status_label.text = "Character Creation will be unlocked in Phase 1!"

func _on_settings_pressed() -> void:
	print("[MainMenu] Settings pressed.")
	if status_label:
		status_label.text = "Settings panel will be implemented in Phase 5."

func _on_quit_pressed() -> void:
	print("[MainMenu] Quit pressed.")
	get_tree().quit()
