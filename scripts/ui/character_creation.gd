extends Control

## CharacterCreation
## UI controller for character creation: handles name entry, class selection,
## inspecting base stats, perks, and confirming character creation.

@onready var name_input: LineEdit = %NameInput
@onready var class_option_button: OptionButton = %ClassOptionButton
@onready var tagline_label: Label = %TaglineLabel
@onready var fantasy_label: Label = %FantasyLabel
@onready var starting_cash_label: Label = %StartingCashLabel

# Stat Labels
@onready var hustle_val_label: Label = %HustleValLabel
@onready var smarts_val_label: Label = %SmartsValLabel
@onready var charisma_val_label: Label = %CharismaValLabel
@onready var stamina_val_label: Label = %StaminaValLabel
@onready var grit_val_label: Label = %GritValLabel

# Mechanic and Perk Labels
@onready var mechanic_title_label: Label = %MechanicTitleLabel
@onready var mechanic_desc_label: Label = %MechanicDescLabel
@onready var perk_title_label: Label = %PerkTitleLabel
@onready var perk_desc_label: Label = %PerkDescLabel
@onready var subclasses_preview_label: Label = %SubclassesPreviewLabel

# Buttons
@onready var confirm_button: Button = %ConfirmButton
@onready var back_button: Button = %BackButton
@onready var error_dialog: AcceptDialog = %ErrorDialog

var available_classes: Array[Dictionary] = []
var selected_class_id: String = ""

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_pressed)
	back_button.pressed.connect(_on_back_pressed)
	class_option_button.item_selected.connect(_on_class_selected)
	
	_populate_classes()

func _populate_classes() -> void:
	class_option_button.clear()
	available_classes = DataLoader.get_all_classes()
	
	if available_classes.is_empty():
		tagline_label.text = "No classes found in data/classes.json."
		confirm_button.disabled = true
		return
	
	for idx in range(available_classes.size()):
		var c = available_classes[idx]
		class_option_button.add_item(c.get("name", "Unknown Class"), idx)
	
	# Default selection to Trader or the first class
	var default_idx = 0
	for i in range(available_classes.size()):
		if available_classes[i].get("id", "") == "trader":
			default_idx = i
			break
	
	class_option_button.select(default_idx)
	_on_class_selected(default_idx)

func _on_class_selected(index: int) -> void:
	if index < 0 or index >= available_classes.size():
		return
	
	var c = available_classes[index]
	selected_class_id = c.get("id", "")
	
	tagline_label.text = "\"%s\"" % c.get("tagline", "")
	fantasy_label.text = c.get("fantasy", "")
	
	var starting_naira = DataLoader.get_starting_naira(selected_class_id)
	starting_cash_label.text = "Starting Capital: %s" % GameState.format_naira(starting_naira)
	
	# Update Base Stats
	var stats = c.get("base_stats", {})
	hustle_val_label.text = str(stats.get("hustle", 1))
	smarts_val_label.text = str(stats.get("street_smarts", 1))
	charisma_val_label.text = str(stats.get("charisma", 1))
	stamina_val_label.text = str(stats.get("stamina", 1))
	grit_val_label.text = str(stats.get("grit", 1))
	
	# Update Signature Mechanic
	mechanic_title_label.text = "Signature: " + c.get("signature_mechanic_name", c.get("signature_mechanic", "").capitalize())
	mechanic_desc_label.text = c.get("signature_mechanic_desc", "")
	
	# Update Passive Perk
	var perk = c.get("passive_perk", {})
	perk_title_label.text = "Passive: " + perk.get("name", perk.get("id", "").capitalize())
	perk_desc_label.text = perk.get("text", "")
	
	# Update Subclasses Preview
	var sub_ids = c.get("subclasses", [])
	var sub_names: Array[String] = []
	for sub_id in sub_ids:
		var sub_data = DataLoader.get_subclass_by_id(sub_id)
		if not sub_data.is_empty():
			sub_names.append(sub_data.get("name", sub_id.capitalize()))
		else:
			sub_names.append(sub_id.replace("_", " ").capitalize())
	
	if not sub_names.is_empty():
		subclasses_preview_label.text = "Subclasses (Unlock at Lvl 5):\n" + ", ".join(sub_names)
	else:
		subclasses_preview_label.text = "Subclasses will unlock at Level 5."

func _on_confirm_pressed() -> void:
	var char_name = name_input.text.strip_edges()
	if char_name.is_empty():
		char_name = "Ayo"
	
	if selected_class_id.is_empty():
		if error_dialog:
			error_dialog.dialog_text = "Please select a character class."
			error_dialog.popup_centered()
		return
	
	var success = GameState.create_character(char_name, selected_class_id)
	if success:
		get_tree().change_scene_to_file("res://scenes/stats_screen.tscn")
	else:
		if error_dialog:
			error_dialog.dialog_text = "Failed to initialize character. Check console logs."
			error_dialog.popup_centered()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
