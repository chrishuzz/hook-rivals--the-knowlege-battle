extends Node2D
class_name Player

const HOOK_SCALE := 3.5
const LINE_WIDTH := 2.0

@onready var boy: Sprite2D = $MangAton
@onready var rod_tip: Marker2D = $MangAton/RodTip
@onready var line: Line2D = $MangAton/RodTip/Line
@onready var hook: Sprite2D = $MangAton/RodTip/Hook


var depth: float = 0.0
var _t: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	_base_y = boy.position.y
	set_depth(0.0)


func set_depth(value: float) -> void:
	depth = maxf(value, 0.0)
	var s := rod_tip.global_scale.abs()
	if s.x <= 0.0001 or s.y <= 0.0001:
		return
	line.width = LINE_WIDTH / s.x
	line.set_point_position(1, Vector2(0, depth / s.y))
	hook.scale = Vector2(HOOK_SCALE, HOOK_SCALE) / s
	var half_h := hook.texture.get_height() * 0.5 * HOOK_SCALE
	hook.position = Vector2(0, (depth + half_h) / s.y)


func hook_rect() -> Rect2:
	var size := Vector2(22, 30)
	return Rect2(hook.global_position - size * 0.5, size)


func _process(delta: float) -> void:
	_t += delta
	boy.position.y = _base_y + roundf(sin(_t * 2.2) * 2.0)
