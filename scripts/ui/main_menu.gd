extends Control

## MainMenu
## Main menu controller for Oshodimushin RPG.
## Handles navigation to Character Creation, Settings, and Game Exit.

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var status_label: Label = %StatusLabel
@onready var info_dialog: AcceptDialog = %InfoDialog

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
	if info_dialog:
		info_dialog.title = "Phase 0 Status"
		info_dialog.dialog_text = "Main Menu is working!\n\nThis is the Phase 0 placeholder.\nCharacter Creation and Gameplay will be built in Phase 1.\n\nTell the agent: 'Phase 0 approved. Start Phase 1.'"
		info_dialog.popup_centered()

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

