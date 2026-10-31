class_name TestMobileLifecycle
extends RefCounted

## Unit tests for Phase 8: Mobile Platform, Lifecycle & Back Navigation

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_mobile_manager_autoload()
	test_modal_stack_push_pop()
	test_safe_area_margins()
	test_safe_area_margin_container_application()
	test_back_action_dismisses_modal()
	test_application_pause_autosave()
	test_export_presets_configuration()
	test_touch_emulation_configured()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_mobile_manager_autoload() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	_assert_true(mm != null, "MobileManager autoload singleton is registered and active")

func test_modal_stack_push_pop() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	if not mm:
		_assert_true(false, "MobileManager not found")
		return
	
	var dummy_modal = Control.new()
	mm.push_modal(dummy_modal)
	_assert_true(mm._modal_stack.has(dummy_modal), "Dummy modal registered in modal stack")
	
	mm.pop_modal(dummy_modal)
	_assert_true(not mm._modal_stack.has(dummy_modal), "Dummy modal popped cleanly from modal stack")
	dummy_modal.free()

func test_safe_area_margins() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	if not mm:
		_assert_true(false, "MobileManager not found")
		return
	
	var margins = mm.get_safe_area_margins()
	_assert_true(margins.has("top") and margins.has("bottom"), "Safe area margins contain top and bottom fields")
	_assert_true(margins.top >= 0 and margins.bottom >= 0, "Top (%d) and bottom (%d) margins are non-negative" % [margins.top, margins.bottom])

func test_safe_area_margin_container_application() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	if not mm:
		_assert_true(false, "MobileManager not found")
		return
	
	var mc = MarginContainer.new()
	mm.apply_safe_area_to_margin(mc, 20, 20)
	
	var top_val = mc.get_theme_constant("margin_top")
	var bottom_val = mc.get_theme_constant("margin_bottom")
	_assert_true(top_val >= 20, "Applied top margin is at least base value (%d >= 20)" % top_val)
	_assert_true(bottom_val >= 20, "Applied bottom margin is at least base value (%d >= 20)" % bottom_val)
	mc.queue_free()

func test_back_action_dismisses_modal() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	if not mm:
		_assert_true(false, "MobileManager not found")
		return
	
	var dummy = Control.new()
	dummy.visible = true
	mm.push_modal(dummy)
	
	mm.handle_back_action()
	_assert_true(not dummy.visible, "Back action closed the topmost open modal")
	dummy.free()

func test_application_pause_autosave() -> void:
	GameState.create_character("MobileTester", "trader")
	GameState.day = 4
	GameState.resources.naira = 75000
	
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	if not mm:
		_assert_true(false, "MobileManager not found")
		return
	
	# Simulate app backgrounding notification
	mm._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	
	_assert_true(SaveSystem.has_autosave(), "Autosave file created on app pause")
	var meta = SaveSystem.get_autosave_metadata()
	_assert_true(meta.get("player_name", "") == "MobileTester", "Autosave preserved character data on pause")

func test_export_presets_configuration() -> void:
	_assert_true(FileAccess.file_exists("res://export_presets.cfg"), "res://export_presets.cfg exists")
	var file = FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		_assert_true("platform=\"Android\"" in content, "Preset targets Android platform")
		_assert_true("package/unique_name=\"com.danfostudios.oshodimushin\"" in content, "Package name matches standard convention")
		_assert_true("gradle_build/min_sdk=\"24\"" in content, "Min SDK is set to 24 (Android 7.0+)")
		_assert_true("gradle_build/target_sdk=\"34\"" in content, "Target SDK is set to 34 (Play Store requirement)")
	else:
		_assert_true(false, "Failed to read export_presets.cfg")

func test_touch_emulation_configured() -> void:
	var touch_from_mouse = ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false)
	var mouse_from_touch = ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	_assert_true(touch_from_mouse, "Touch from mouse emulation is enabled for responsive mobile gestures")
	_assert_true(mouse_from_touch, "Mouse from touch emulation is enabled for UI controls")
