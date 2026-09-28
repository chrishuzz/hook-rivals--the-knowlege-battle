
func _on_start_button_pressed():
	GameManager.current_difficulty = GameManager.Difficulty.EASY
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://shore.tscn")
