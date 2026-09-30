extends Node2D

@onready var play_button: Button = $UI/PlayButton
@onready var board_button: Button = $UI/BoardButton
@onready var credits_button: Button = $UI/NameButton
@onready var settings_button: Button = $UI/QuitButton


func _ready() -> void:
	
	play_button.pressed.connect(_go.bind("res://scenes/area_selection.tscn"))
	board_button.pressed.connect(_go.bind("res://scenes/leaderboard.tscn"))
	credits_button.pressed.connect(_go.bind("res://scenes/CREDITS.tscn"))
	settings_button.pressed.connect(_go.bind("res://scenes/CREDITS.tscn"))
	play_button.grab_focus()


func _go(path: String) -> void:
	Global.play_sfx("click")
	get_tree().change_scene_to_file(path)
