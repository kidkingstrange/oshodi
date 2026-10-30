extends Control

## SubclassSelect
## Controller for choosing a subclass specialization once reaching Level 5.
## Displays all 6 subclasses for the player's class with fantasy, perks, and weakness.

const Levelling = preload("res://scripts/core/levelling.gd")

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var subclasses_vbox: VBoxContainer = %SubclassesVBox
@onready var back_button: Button = %BackButton
@onready var confirm_dialog: ConfirmationDialog = %ConfirmDialog

var selected_subclass_id: String = ""

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_subclass)
	
	var class_data = DataLoader.get_class_by_id(GameState.class_id)
	var class_name_str = class_data.get("name", "Hustler")
	title_label.text = "LEVEL 5 BREAKTHROUGH: %s" % class_name_str.to_upper()
	desc_label.text = "Your reputation has grown in Oshodi! Choose your permanent specialization subclass to unlock unique street perks."
	
	_render_subclasses()

func _render_subclasses() -> void:
	for child in subclasses_vbox.get_children():
		child.queue_free()
	
	var list = DataLoader.get_subclasses_for_class(GameState.class_id)
	for sc in list:
		var panel = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_bottom", 12)
		panel.add_child(margin)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = sc.get("name", "").to_upper()
		name_lbl.theme_override_font_sizes.font_size = 18
		name_lbl.theme_override_colors.font_color = Color(0.85, 0.45, 0.05, 1)
		vbox.add_child(name_lbl)
		
		var fantasy_lbl = Label.new()
		fantasy_lbl.text = "\"%s\"" % sc.get("fantasy", "")
		fantasy_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fantasy_lbl.theme_override_font_sizes.font_size = 13
		fantasy_lbl.theme_override_colors.font_color = Color(0.2, 0.25, 0.3, 1)
		vbox.add_child(fantasy_lbl)
		
		var perks = sc.get("perks", [])
		for p in perks:
			var p_lbl = Label.new()
			p_lbl.text = "★ Perk: %s — %s" % [p.get("name", ""), p.get("text", "")]
			p_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			p_lbl.theme_override_font_sizes.font_size = 12
			p_lbl.theme_override_colors.font_color = Color(0.12, 0.52, 0.25, 1)
			vbox.add_child(p_lbl)
		
		var weakness_lbl = Label.new()
		weakness_lbl.text = "⚠ Weakness: %s" % sc.get("weakness", "None")
		weakness_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		weakness_lbl.theme_override_font_sizes.font_size = 12
		weakness_lbl.theme_override_colors.font_color = Color(0.75, 0.2, 0.2, 1)
		vbox.add_child(weakness_lbl)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 44)
		btn.text = "Select %s" % sc.get("name", "")
		var sc_id = sc.get("id", "")
		btn.pressed.connect(func(): _prompt_confirm_subclass(sc_id, sc.get("name", "")))
		vbox.add_child(btn)
		
		subclasses_vbox.add_child(panel)

func _prompt_confirm_subclass(sc_id: String, sc_name: String) -> void:
	selected_subclass_id = sc_id
	confirm_dialog.dialog_text = "Are you sure you want to specialize as a %s?\n\nThis will permanently unlock your subclass perks!" % sc_name
	confirm_dialog.popup_centered()

func _on_confirm_subclass() -> void:
	if selected_subclass_id.is_empty():
		return
	var res = Levelling.apply_subclass(selected_subclass_id)
	if res.get("success", false):
		get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
	else:
		confirm_dialog.dialog_text = res.get("message", "Could not apply subclass.")
		confirm_dialog.popup_centered()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
