extends Node2D
class_name Fish

const TEXTURE_PATHS := [
	"res://assets/fish_orange.png", "res://assets/fish_blue.png", "res://assets/fish_pink.png",
	"res://assets/fish_green.png", "res://assets/fish_yellow.png",
]
const SPRITE_SIZE := Vector2(28, 18)
const FISH_SCALE := 2.5
const SIZE := SPRITE_SIZE * FISH_SCALE         
const LETTER_FONT_SIZE := 16

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
	body.scale = Vector2(FISH_SCALE, FISH_SCALE)
	body.flip_h = dir < 0
	label.text = letter
	label.add_theme_font_size_override("font_size", LETTER_FONT_SIZE)
	label.size = SIZE
	label.position = -SIZE * 0.5 + Vector2(dir * 2.0 * FISH_SCALE, 0)


func get_rect() -> Rect2:
	return Rect2(global_position - SIZE * 0.5, SIZE)


func _process(delta: float) -> void:
	if is_caught:
		return
	position.x += dir * speed * delta
	_wobble += delta * 2.0
	position.y = _base_y + sin(_wobble) * 5.0
