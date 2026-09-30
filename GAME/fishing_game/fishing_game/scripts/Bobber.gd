extends RigidBody3D

signal landed

var water_y: float = 0.0
var floating := false
var bob_time := 0.0
var bob_amplitude := 0.03

func _physics_process(delta: float) -> void:
	if not floating:
		if global_position.y <= water_y:
			global_position.y = water_y
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			freeze = true
			floating = true
			emit_signal("landed")
	else:
		bob_time += delta
		global_position.y = water_y + sin(bob_time * 2.0) * bob_amplitude
		# Ease the bite-bob back down to a gentle idle bob.
		bob_amplitude = lerp(bob_amplitude, 0.03, delta * 2.0)

func do_bite_bob() -> void:
	bob_time = 0.0
	bob_amplitude = 0.18
