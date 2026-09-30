extends Node2D


const COLUMN_WIDTHS := [30, 110, 64, 56]

@onready var grid: GridContainer = $UI/Panel/Margin/VBox/Grid
@onready var empty_label: Label = $UI/Panel/Margin/VBox/EmptyLabel
@onready var back_button: Button = $UI/Panel/Margin/VBox/BackButton


func _ready() -> void:
	back_button.pressed.connect(_back)
	_add_row(["#", "NAME", "SCORE", "WORDS"], Color("ffe14d"))
	for i in Global.scores.size():
		var e: Dictionary = Global.scores[i]
		var col := Color.WHITE
		if i + 1 == Global.last_rank:
			col = Color("7be07b")
		elif str(e["name"]) == Global.player_name:
			col = Color("8fd3f4")
		_add_row([str(i + 1), str(e["name"]), str(int(e["score"])), str(int(e["words"]))], col)
	empty_label.visible = Global.scores.is_empty()
	back_button.grab_focus()


func _add_row(cells: Array, col: Color) -> void:
	for i in 4:
		var l := Label.new()
		l.text = cells[i]
		l.custom_minimum_size = Vector2(COLUMN_WIDTHS[i], 11)
		l.add_theme_color_override("font_color", col)
		if i >= 2:
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(l)


func _back() -> void:
	Global.last_rank = -1
	Global.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
