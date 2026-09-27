extends Node3D
## Drives the whole fishing loop:
## IDLE -> CHARGING -> CASTING -> WAITING -> BITE -> REELING -> IDLE

enum State { IDLE, CHARGING, CASTING, WAITING, BITE, REELING }
var state: int = State.IDLE

@export var bobber_scene: PackedScene
@export var water_y: float = -0.15
@export var rod_tip_path: NodePath
@export var cast_max_power: float = 14.0
@export var cast_min_power: float = 4.0

var charge_time := 0.0
var charge_max_time := 1.4
var bobber: RigidBody3D = null
var current_fish = null
var bite_timer := 0.0
var bite_window := 0.0

# Reel minigame state
var tension := 0.5      # 0..1 — must be kept inside the target zone
var progress := 0.0     # 0..1 — catch the fish at 1.0
var target_center := 0.5
var target_width := 0.25
var fish_pull_dir := 1.0
var fish_pull_timer := 0.0

signal state_changed(new_state)
signal cast_power_changed(power_ratio)
signal bite_started
signal reel_updated(tension, progress, target_center, target_width)
signal fish_caught(fish_name, weight_kg, rarity, points)
signal fish_escaped(reason)

@onready var rod_tip: Node3D = get_node(rod_tip_path)

func _process(delta: float) -> void:
	match state:
		State.CHARGING:
			charge_time = min(charge_time + delta, charge_max_time)
			emit_signal("cast_power_changed", charge_time / charge_max_time)
			if Input.is_action_just_released("fish_action"):
				_do_cast()
		State.WAITING:
			bite_timer -= delta
			if bite_timer <= 0.0:
				_start_bite()
		State.BITE:
			bite_window -= delta
			if Input.is_action_just_pressed("fish_action"):
				_start_reel()
			elif bite_window <= 0.0:
				emit_signal("fish_escaped", "too_slow")
				_reset_line()
		State.REELING:
			_process_reel(delta)

func _unhandled_input(event: InputEvent) -> void:
	if state == State.IDLE and event.is_action_pressed("fish_action"):
		_start_charge()

func _start_charge() -> void:
	state = State.CHARGING
	charge_time = 0.0
	emit_signal("state_changed", state)

func _do_cast() -> void:
	var power_ratio: float = charge_time / charge_max_time
	var power: float = lerp(cast_min_power, cast_max_power, power_ratio)
	state = State.CASTING
	emit_signal("state_changed", state)

	bobber = bobber_scene.instantiate()
	get_tree().current_scene.add_child(bobber)
	bobber.global_position = rod_tip.global_position
	var cam := get_viewport().get_camera_3d()
	var dir: Vector3 = -cam.global_transform.basis.z
	dir.y = clamp(dir.y, 0.05, 0.6)
	bobber.linear_velocity = dir.normalized() * power + Vector3.UP * (power * 0.35)
	bobber.water_y = water_y
	bobber.connect("landed", Callable(self, "_on_bobber_landed"))

func _on_bobber_landed() -> void:
	current_fish = FishDB.roll_fish()
	bite_timer = randf_range(current_fish.bite_delay_min, current_fish.bite_delay_max)
	state = State.WAITING
	emit_signal("state_changed", state)

func _start_bite() -> void:
	state = State.BITE
	bite_window = clamp(0.9 - current_fish.difficulty * 0.4, 0.35, 0.9)
	if bobber:
		bobber.do_bite_bob()
	emit_signal("bite_started")
	emit_signal("state_changed", state)

func _start_reel() -> void:
	state = State.REELING
	tension = 0.5
	progress = 0.0
	target_center = 0.5
	target_width = max(0.35 - current_fish.difficulty * 0.18, 0.12)
	fish_pull_dir = 1.0 if randf() > 0.5 else -1.0
	fish_pull_timer = 0.0
	emit_signal("state_changed", state)

func _process_reel(delta: float) -> void:
	fish_pull_timer -= delta
	if fish_pull_timer <= 0.0:
		fish_pull_dir *= -1.0
		fish_pull_timer = randf_range(0.4, 1.1) * (1.0 - current_fish.difficulty * 0.4)
		target_center = clamp(target_center + randf_range(-0.15, 0.15), target_width, 1.0 - target_width)

	var pull_speed: float = (0.5 + current_fish.difficulty) * 0.6
	tension += fish_pull_dir * pull_speed * delta

	if Input.is_action_pressed("fish_action"):
		tension -= 1.1 * delta

	tension = clamp(tension, 0.0, 1.0)

	var in_zone: bool = abs(tension - target_center) <= target_width
	if in_zone:
		progress += delta * 0.35
	else:
		progress -= delta * 0.15
	progress = clamp(progress, 0.0, 1.0)

	emit_signal("reel_updated", tension, progress, target_center, target_width)

	if tension <= 0.02 or tension >= 0.98:
		emit_signal("fish_escaped", "line_snapped")
		_reset_line()
	elif progress >= 1.0:
		var weight_kg: float = randf_range(current_fish.min_kg, current_fish.max_kg)
		emit_signal("fish_caught", current_fish.name, weight_kg, current_fish.rarity, current_fish.points)
		_reset_line()

func _reset_line() -> void:
	if bobber and is_instance_valid(bobber):
		bobber.queue_free()
	bobber = null
	current_fish = null
	state = State.IDLE
	emit_signal("state_changed", state)
