extends Node2D
class_name Fish

const TEXTURE_PATHS := [
	"res://assets/fish_orange.png", "res://assets/fish_blue.png", "res://assets/fish_pink.png",
	"res://assets/fish_green.png", "res://assets/fish_yellow.png",
]
const SIZE := Vector2(28, 18)

@onready var body: Sprite2D = $Body
@onready var label: Label = $Letter

var letter: String = "A"
var speed: float = 40.0
var dir: int = 1
var is_caught: bool = false
var _wobble: float = randf() * TAU
var _base_y: float = 0.0


func setup(p_letter: String, color_idx: int, p_speed: float, p_dir: int) -> void:
	letter = p_letter
	speed = p_speed
	dir = p_dir
	_base_y = position.y
	body.texture = load(TEXTURE_PATHS[color_idx % TEXTURE_PATHS.size()])
	body.flip_h = dir < 0
	label.text = letter
	label.size = Vector2(26, 8)
	label.position = Vector2(-15 if dir < 0 else -11, -4)


func get_rect() -> Rect2:
	return Rect2(global_position - SIZE / 2.0, SIZE)


func _process(delta: float) -> void:
	if is_caught:
		return
	position.x += dir * speed * delta
	_wobble += delta * 2.0
	position.y = _base_y + sin(_wobble) * 2.0
