extends Control

@onready var name_input: LineEdit = $CenterContainer/VBoxContainer/NameInput
@onready var error_label: Label = $CenterContainer/VBoxContainer/ErrorLabel

func _on_play_pressed() -> void:
	_try_play()

func _on_name_submitted(_text: String) -> void:
	_try_play()

func _try_play() -> void:
	var entered := name_input.text.strip_edges()
	if entered.is_empty():
		error_label.visible = true
		return
	error_label.visible = false
	Global.player_name = entered
	Global.reset_game()
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://leader_board.tscn")
