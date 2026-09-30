extends TextureProgressBar


@export var next_scene_path: String = "res://random_control.tscn"
@export var min_display_time: float = 10.0  

var loading_progress := []
var is_loading := false
var scene_ready := false
var next_scene: PackedScene = null
var elapsed_time := 0.0

func _ready() -> void:
	min_value = 0
	max_value = 100
	value = 0

	var err = ResourceLoader.load_threaded_request(next_scene_path)
	if err != OK:
		push_error("Failed to start loading: " + next_scene_path)
		return

	is_loading = true

func _process(delta: float) -> void:
	if not is_loading:
		return

	elapsed_time += delta

	if not scene_ready:
		var status = ResourceLoader.load_threaded_get_status(next_scene_path, loading_progress)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				next_scene = ResourceLoader.load_threaded_get(next_scene_path)
				scene_ready = true

			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Load failed: " + next_scene_path)
				is_loading = false
				return

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Invalid resource: " + next_scene_path)
				is_loading = false
				return

	var time_ratio = clamp(elapsed_time / min_display_time, 0.0, 1.0)
	value = time_ratio * 100

	if elapsed_time >= min_display_time and scene_ready:
		is_loading = false
		get_tree().change_scene_to_packed(next_scene)
