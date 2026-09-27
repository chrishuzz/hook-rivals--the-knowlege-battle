extends Node
## Registers input actions in code at startup so the project works
## immediately without needing to hand-edit the Input Map in the editor.

func _ready() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("jump", KEY_SPACE)
	_add_mouse_action("fish_action", MOUSE_BUTTON_LEFT)


func _add_key_action(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var ev := InputEventKey.new()
	ev.keycode = keycode
	InputMap.action_add_event(action_name, ev)


func _add_mouse_action(action_name: String, button_index: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var ev := InputEventMouseButton.new()
	ev.button_index = button_index
	InputMap.action_add_event(action_name, ev)
