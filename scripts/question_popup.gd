extends CanvasLayer
class_name QuestionPopup


signal answered(correct: bool)

@onready var tier_label: Label = $Panel/Margin/VBox/TierLabel
@onready var question_label: Label = $Panel/Margin/VBox/QuestionLabel
@onready var answers_box: VBoxContainer = $Panel/Margin/VBox/Answers
@onready var feedback_label: Label = $Panel/Margin/VBox/FeedbackLabel

var _buttons: Array[Button] = []
var _correct_index := -1
var _locked := true


func _ready() -> void:
	visible = false
	for child in answers_box.get_children():
		var b := child as Button
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(_on_pressed.bind(_buttons.size()))
		_buttons.append(b)


func ask(q: Dictionary, tier: int, fish_letter: String) -> void:
	var options: Array = q["options"].duplicate()
	var correct_text: String = options[int(q["answer"])]
	options.shuffle()
	_correct_index = options.find(correct_text)
	tier_label.text = "FISH '%s' - %s QUESTION" % [fish_letter, Global.TIER_NAMES[tier]]
	tier_label.add_theme_color_override("font_color", Global.TIER_COLORS[tier])
	question_label.text = q["q"]
	feedback_label.text = "PRESS 1-4 OR CLICK AN ANSWER"
	feedback_label.add_theme_color_override("font_color", Color("8fa3c4"))
	for i in _buttons.size():
		_buttons[i].text = "%d) %s" % [i + 1, options[i]] if i < options.size() else ""
		_buttons[i].visible = i < options.size()
		_buttons[i].modulate = Color.WHITE
	_locked = true
	visible = true
	await get_tree().create_timer(0.35, true).timeout   
	_locked = false


func _input(event: InputEvent) -> void:
	if not visible or _locked:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var idx: int = event.keycode - KEY_1
		if idx >= 0 and idx < _buttons.size() and _buttons[idx].visible:
			get_viewport().set_input_as_handled()
			_on_pressed(idx)


func _on_pressed(index: int) -> void:
	if _locked:
		return
	_locked = true
	var correct := index == _correct_index
	_buttons[_correct_index].modulate = Color(0.55, 1.0, 0.55)
	if correct:
		feedback_label.text = "CORRECT!"
		feedback_label.add_theme_color_override("font_color", Color("7be07b"))
	else:
		_buttons[index].modulate = Color(1.0, 0.5, 0.5)
		feedback_label.text = "WRONG!"
		feedback_label.add_theme_color_override("font_color", Color("ff6b6b"))
	await get_tree().create_timer(1.0, true).timeout
	visible = false
	answered.emit(correct)
