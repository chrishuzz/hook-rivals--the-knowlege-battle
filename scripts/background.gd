extends Node2D


@onready var waves: Sprite2D = $Waves
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	waves.position.x = -fmod(_t * 10.0, 16.0)
