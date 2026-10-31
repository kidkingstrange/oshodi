extends Control

## DialogueOverlay
## Fullscreen overlay for conversing with neighbourhood NPCs per docs/03_DATA_SCHEMAS.md.

signal dialogue_finished

@onready var npc_name_label: Label = %NpcNameLabel
@onready var npc_role_label: Label = %NpcRoleLabel
@onready var dialogue_text_label: Label = %DialogueTextLabel
@onready var options_vbox: VBoxContainer = %OptionsVBox
@onready var effects_pill_label: Label = %EffectsPillLabel
@onready var close_button: Button = %CloseButton

var current_npc_id: String = ""
var current_dialogue: Dictionary = {}

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

## Opens conversation with the target NPC.
func start_conversation(npc_id: String) -> void:
	current_npc_id = npc_id
	var npc = DataLoader.get_npc_by_id(npc_id)
	if npc.is_empty():
		queue_free()
		return
	
	if npc_name_label:
		npc_name_label.text = npc.get("name", "Local Resident").to_upper()
	if npc_role_label:
		npc_role_label.text = npc.get("role", "Neighbourhood Face")
	
	current_dialogue = DialogueManager.get_starting_dialogue_for_npc(npc_id)
	_display_dialogue_node(current_dialogue)
	visible = true

func _display_dialogue_node(d_node: Dictionary) -> void:
	current_dialogue = d_node
	
	if effects_pill_label:
		effects_pill_label.visible = false
	
	for child in options_vbox.get_children():
		child.queue_free()
	
	if d_node.is_empty():
		dialogue_text_label.text = "Safe travels on your route today!"
		_add_finish_button()
		return
	
	var lines = d_node.get("lines", [])
	if not lines.is_empty():
		dialogue_text_label.text = lines[0].get("text", "...")
	else:
		dialogue_text_label.text = "..."
	
	var options = d_node.get("options", [])
	if options.is_empty():
		_add_finish_button()
	else:
		for opt in options:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(0, 50)
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.text = opt.get("label", "Continue")
			btn.pressed.connect(_on_option_selected.bind(opt))
			options_vbox.add_child(btn)

func _add_finish_button() -> void:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(0, 50)
	btn.text = "Walk Away / Return to Street"
	btn.pressed.connect(_on_close_pressed)
	options_vbox.add_child(btn)

func _on_option_selected(opt_dict: Dictionary) -> void:
	SoundManager.play_click()
	var applied = DialogueManager.apply_option_effects(opt_dict)
	
	# Show effects pill if any
	if not applied.is_empty() and effects_pill_label:
		var effect_strs: Array[String] = []
		for k in applied:
			var v = applied[k]
			var sign_str = "+" if v > 0 else ""
			effect_strs.append("%s %s%d" % [k.capitalize(), sign_str, v])
		effects_pill_label.text = "Effects: " + ", ".join(effect_strs)
		effects_pill_label.visible = true
	
	var next_id = opt_dict.get("next_dialogue_id", null)
	if next_id != null and not str(next_id).is_empty():
		var next_node = DataLoader.get_dialogue_by_id(str(next_id))
		_display_dialogue_node(next_node)
	else:
		_add_finish_button()

func _on_close_pressed() -> void:
	SoundManager.play_click()
	dialogue_finished.emit()
	queue_free()
