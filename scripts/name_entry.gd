extends Node2D

@onready var name_edit: LineEdit = $UI/NameEdit
@onready var error_label: Label = $UI/ErrorLabel
@onready var start_button: Button = $UI/StartButton


func _ready() -> void:
	name_edit.text = Global.player_name        
	name_edit.caret_column = name_edit.text.length()
	name_edit.grab_focus()
	name_edit.text_submitted.connect(func(_t: String): _submit())
	start_button.pressed.connect(_submit)


func _submit() -> void:
	var n := name_edit.text.strip_edges()
	if n.is_empty():
		error_label.text = "PLEASE TYPE YOUR NAME!"
		Global.play_sfx("wrong")
		return
	Global.set_player_name(n)
	Global.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
