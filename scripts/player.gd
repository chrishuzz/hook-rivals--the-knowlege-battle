extends Node2D
class_name Player

@onready var boy: Sprite2D = $MangAton 
@onready var rod_tip: Marker2D = $MangAton/RodTip
@onready var line: Line2D = $MangAton/RodTip/Line
@onready var hook: Sprite2D = $MangAton/RodTip/Hook

var depth: float = 0.0
var _t: float = 0.0


func set_depth(value: float) -> void:
	depth = maxf(value, 0.0)
	line.set_point_position(1, Vector2(0, depth))
	hook.position = Vector2(0, depth + 5.0)


func hook_rect() -> Rect2:
	return Rect2(hook.global_position - Vector2(5, 6), Vector2(10, 12))


func _process(delta: float) -> void:
	_t += delta
	boy.position.y = roundf(sin(_t * 2.2))   
