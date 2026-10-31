extends Control

## ShopScreen
## Controller for buying items and selling inventory goods per docs/07_UI_UX_GUIDE.md.
## Provides Buy/Sell modes, displays Naira and carry weight, and supports consumables usage.

const ShopManager = preload("res://scripts/core/shop_manager.gd")
const InventoryManager = preload("res://scripts/core/inventory_manager.gd")

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var naira_label: Label = %NairaLabel
@onready var weight_label: Label = %WeightLabel
@onready var buy_tab_btn: Button = %BuyTabButton
@onready var sell_tab_btn: Button = %SellTabButton
@onready var items_container: VBoxContainer = %ItemsContainer
@onready var back_button: Button = %BackButton
@onready var notice_dialog: AcceptDialog = %NoticeDialog

var is_buy_mode: bool = true

func _ready() -> void:
	buy_tab_btn.pressed.connect(_on_buy_tab_pressed)
	sell_tab_btn.pressed.connect(_on_sell_tab_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	GameState.resources_changed.connect(func(_r): _update_header())
	
	_update_header()
	_refresh_list()

func _update_header() -> void:
	var loc = DataLoader.get_location_by_id(GameState.location_id)
	title_label.text = ("MARKET STALL: %s" % loc.get("name", "Oshodi")).to_upper()
	naira_label.text = "Naira: %s" % GameState.format_naira(GameState.resources.naira)
	var cur_w = InventoryManager.get_total_weight()
	var max_w = InventoryManager.get_max_weight()
	weight_label.text = "Load: %d/%d kg" % [cur_w, max_w]

func _on_buy_tab_pressed() -> void:
	is_buy_mode = true
	buy_tab_btn.disabled = true
	sell_tab_btn.disabled = false
	subtitle_label.text = "Available goods for purchase at this location:"
	_refresh_list()

func _on_sell_tab_pressed() -> void:
	is_buy_mode = false
	buy_tab_btn.disabled = false
	sell_tab_btn.disabled = true
	subtitle_label.text = "Your inventory items available for sale:"
	_refresh_list()

func _refresh_list() -> void:
	for child in items_container.get_children():
		child.queue_free()
	
	if is_buy_mode:
		_render_buy_items()
	else:
		_render_sell_items()

func _render_buy_items() -> void:
	var shop_items = ShopManager.get_shop_inventory(GameState.location_id)
	if shop_items.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No trade goods or stock available at this location."
		empty_lbl.theme_override_colors.font_color = Color(0.4, 0.4, 0.4, 1)
		items_container.add_child(empty_lbl)
		return
	
	for item in shop_items:
		var card = _create_item_card(item, true)
		items_container.add_child(card)

func _render_sell_items() -> void:
	if GameState.inventory.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Your bag is empty! Buy stock or trade goods first."
		empty_lbl.theme_override_colors.font_color = Color(0.4, 0.4, 0.4, 1)
		items_container.add_child(empty_lbl)
		return
	
	for entry in GameState.inventory:
		var item_id = entry.get("id", "")
		var item_data = DataLoader.get_item_by_id(item_id)
		if not item_data.is_empty():
			var card = _create_item_card(item_data, false, int(entry.get("quantity", 1)))
			items_container.add_child(card)

func _create_item_card(item: Dictionary, for_buying: bool, owned_qty: int = -1) -> PanelContainer:
	var panel = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)
	
	# Top row: Name and Price
	var top_row = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = item.get("name", "Unknown Item")
	name_lbl.theme_override_font_sizes.font_size = 16
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(name_lbl)
	
	var price_lbl = Label.new()
	var unit_price = int(item.get("buy_price", 0)) if for_buying else int(item.get("sell_price", 0))
	if not for_buying and GameState.class_id == "trader":
		unit_price = int(unit_price * 1.15)
	
	price_lbl.text = ("Buy: %s" if for_buying else "Sell: %s") % GameState.format_naira(unit_price)
	price_lbl.theme_override_font_sizes.font_size = 15
	price_lbl.theme_override_colors.font_color = Color(0.12, 0.58, 0.28, 1) if not for_buying else Color(0.85, 0.45, 0.05, 1)
	top_row.add_child(price_lbl)
	vbox.add_child(top_row)
	
	# Middle row: Description & Stats
	var desc_lbl = Label.new()
	var desc_text = item.get("description", "")
	var weight = int(item.get("weight", 1))
	var cat = item.get("category", "General").capitalize()
	var owned_count = InventoryManager.get_item_count(item.get("id", ""))
	
	desc_lbl.text = "%s\nType: %s • Weight: %d kg • Owned: %d" % [desc_text, cat, weight, owned_count]
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.theme_override_font_sizes.font_size = 13
	desc_lbl.theme_override_colors.font_color = Color(0.3, 0.35, 0.4, 1)
	vbox.add_child(desc_lbl)
	
	# Action Button Row
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	
	var action_btn = Button.new()
	action_btn.custom_minimum_size = Vector2(120, 42)
	action_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var item_id = item.get("id", "")
	
	if for_buying:
		action_btn.text = "Buy 1 Unit"
		action_btn.pressed.connect(func(): _on_buy_clicked(item_id))
	else:
		action_btn.text = "Sell 1 Unit"
		action_btn.pressed.connect(func(): _on_sell_clicked(item_id))
	btn_row.add_child(action_btn)
	
	# Consumable Use Button (if consumable and in inventory)
	if item.get("type", "") == "consumable" and owned_count > 0:
		var use_btn = Button.new()
		use_btn.custom_minimum_size = Vector2(100, 42)
		use_btn.text = "Consume"
		use_btn.pressed.connect(func(): _on_consume_clicked(item_id))
		btn_row.add_child(use_btn)
	
	vbox.add_child(btn_row)
	return panel

func _on_buy_clicked(item_id: String) -> void:
	var res = ShopManager.buy_item(item_id, 1)
	if res.get("success", false):
		SoundManager.play_cash()
	else:
		SoundManager.play_fail()
	_show_notice(res.get("message", "Purchase complete."))
	_update_header()
	_refresh_list()

func _on_sell_clicked(item_id: String) -> void:
	var res = ShopManager.sell_item(item_id, 1)
	if res.get("success", false):
		SoundManager.play_cash()
	else:
		SoundManager.play_fail()
	_show_notice(res.get("message", "Sale complete."))
	_update_header()
	_refresh_list()

func _on_consume_clicked(item_id: String) -> void:
	var res = InventoryManager.use_consumable(item_id)
	if res.get("success", false):
		SoundManager.play_success()
	else:
		SoundManager.play_fail()
	_show_notice(res.get("message", "Consumed."))
	_update_header()
	_refresh_list()

func _show_notice(msg: String) -> void:
	notice_dialog.dialog_text = msg
	notice_dialog.popup_centered()

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
