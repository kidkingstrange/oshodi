extends Control

## StyleGuide
## Demonstrates and verifies Option A: "Danfo Poster" design system
## per docs/07_UI_UX_GUIDE.md. Displays palette swatches, typography,
## poster cards with thick outlines, buttons, and resource chips.

@onready var back_button: Button = %BackButton

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
