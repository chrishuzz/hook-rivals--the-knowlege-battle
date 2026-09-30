extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
<<<<<<< HEAD
	get_tree().change_scene_to_file("res://leader_board.tscn")
=======
	get_tree().change_scene_to_file("res://my_records_control.tscn")
>>>>>>> 205011049d599d3336b96b7b7f5df1f969bab341
