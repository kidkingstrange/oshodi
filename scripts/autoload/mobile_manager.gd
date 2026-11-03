extends Node

## MobileManager
## Autoload singleton managing Android mobile platform features:
## - Hardware/gesture Back button navigation and modal dismissal.
## - App lifecycle (backgrounding, pause/resume, autosave on pause).
## - Safe-area margins for notch cutouts and gesture pill navigation.
## - Responsive touch target validation.

signal back_pressed()
signal safe_area_changed(margins: Dictionary)

## Stack of active overlay modals or dialogs (topmost receives back first).
var _modal_stack: Array[Node] = []
var modal_stack: Array[Node]:
	get:
		return _modal_stack

func clear_modal_stack() -> void:
	_modal_stack.clear()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			handle_back_action()
		NOTIFICATION_APPLICATION_PAUSED:
			_on_application_paused()
		NOTIFICATION_APPLICATION_RESUMED:
			_on_application_resumed()
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			_on_focus_lost()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BACK:
			handle_back_action()
			get_viewport().set_input_as_handled()

## Handles Android system back button or escape key.
## First dismisses any open modal in the modal stack.
## If no modal is open, delegates back to the active scene.
func handle_back_action() -> void:
	back_pressed.emit()
	
	# 1. Check modal stack
	while _modal_stack.size() > 0:
		var top_modal = _modal_stack.pop_back()
		if is_instance_valid(top_modal) and top_modal.visible:
			if top_modal is AcceptDialog:
				top_modal.hide()
			elif top_modal.has_method("close"):
				top_modal.call("close")
			else:
				top_modal.visible = false
			return
	
	# 2. Check current scene navigation
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	var scene_path = current_scene.scene_file_path
	if scene_path.ends_with("main_menu.tscn"):
		# On main menu, ask to confirm exit or minimize app
		if OS.get_name() == "Android":
			# On Android, allow OS to handle app exit/minimize
			pass
	elif scene_path.ends_with("hub_screen.tscn"):
		# In hub screen, save and prompt or return to main menu
		if current_scene.has_method("on_back_pressed"):
			current_scene.call("on_back_pressed")
		else:
			SaveSystem.save_autosave()
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif scene_path.ends_with("character_creation.tscn") or scene_path.ends_with("settings_screen.tscn"):
		# Secondary screens return cleanly to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif scene_path.ends_with("style_guide.tscn"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

## Registers a modal dialog to receive priority dismissal on Back press.
func push_modal(modal_node: Node) -> void:
	if is_instance_valid(modal_node) and not _modal_stack.has(modal_node):
		_modal_stack.append(modal_node)

## Removes a modal dialog from the back stack when closed normally.
func pop_modal(modal_node: Node) -> void:
	_modal_stack.erase(modal_node)

## Returns safe area margins (top, bottom, left, right) in design pixels.
## Adapts for display cutouts (camera notches) and gesture navigation pills.
func get_safe_area_margins() -> Dictionary:
	var screen_rect = DisplayServer.get_display_safe_area()
	var screen_size = DisplayServer.screen_get_size()
	
	if screen_size.x <= 0 or screen_size.y <= 0:
		# Fallback standard margins for desktop testing
		return {"top": 0, "bottom": 0, "left": 0, "right": 0}
	
	var window_size = get_viewport().get_visible_rect().size
	var scale_x = window_size.x / float(screen_size.x)
	var scale_y = window_size.y / float(screen_size.y)
	
	var top = int(screen_rect.position.y * scale_y)
	var bottom = int((screen_size.y - (screen_rect.position.y + screen_rect.size.y)) * scale_y)
	var left = int(screen_rect.position.x * scale_x)
	var right = int((screen_size.x - (screen_rect.position.x + screen_rect.size.x)) * scale_x)
	
	return {
		"top": maxi(0, top),
		"bottom": maxi(0, bottom),
		"left": maxi(0, left),
		"right": maxi(0, right)
	}

## Applies safe-area padding automatically to a MarginContainer root.
func apply_safe_area_to_margin(margin_container: MarginContainer, base_top: int = 16, base_bottom: int = 16) -> void:
	if not is_instance_valid(margin_container):
		return
	var safe = get_safe_area_margins()
	margin_container.add_theme_constant_override("margin_top", base_top + safe.top)
	margin_container.add_theme_constant_override("margin_bottom", base_bottom + safe.bottom)
	if safe.left > 0:
		margin_container.add_theme_constant_override("margin_left", safe.left)
	if safe.right > 0:
		margin_container.add_theme_constant_override("margin_right", safe.right)

func _on_application_paused() -> void:
	# Trigger seamless autosave on app backgrounding
	if GameState.has_character():
		SaveSystem.save_autosave()

func _on_application_resumed() -> void:
	pass

func _on_focus_lost() -> void:
	if GameState.has_character():
		SaveSystem.save_autosave()
