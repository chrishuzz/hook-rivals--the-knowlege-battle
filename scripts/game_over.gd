extends CanvasLayer
class_name GameOverPanel


@onready var name_label: Label = $Panel/Margin/VBox/NameLabel
@onready var score_label: Label = $Panel/Margin/VBox/ScoreLabel
@onready var stats_label: Label = $Panel/Margin/VBox/StatsLabel
@onready var rank_label: Label = $Panel/Margin/VBox/RankLabel
@onready var again_button: Button = $Panel/Margin/VBox/Buttons/AgainButton
@onready var board_button: Button = $Panel/Margin/VBox/Buttons/BoardButton
@onready var menu_button: Button = $Panel/Margin/VBox/Buttons/MenuButton


func _ready() -> void:
	visible = false
	again_button.pressed.connect(_go.bind("res://scenes/game.tscn"))
	board_button.pressed.connect(_go.bind("res://scenes/leaderboard.tscn"))
	menu_button.pressed.connect(_go.bind("res://scenes/main_menu.tscn"))


func show_results(score: int, words: int, fish: int, rank: int) -> void:
	name_label.text = Global.player_name
	score_label.text = "SCORE: %d" % score
	stats_label.text = "WORDS: %d   FISH: %d" % [words, fish]
	if rank > 0:
		rank_label.text = "YOU ARE #%d ON THE LEADERBOARD!" % rank
		rank_label.add_theme_color_override("font_color", Color("7be07b"))
	else:
		rank_label.text = "NOT IN THE TOP %d - TRY AGAIN!" % Global.MAX_ENTRIES
		rank_label.add_theme_color_override("font_color", Color("ffd93d"))
	visible = true


func _go(path: String) -> void:
	Global.play_sfx("click")
	get_tree().change_scene_to_file(path)
