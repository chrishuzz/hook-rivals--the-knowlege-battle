
extends Node

enum Difficulty { EASY, MEDIUM, HARD }

var current_difficulty: Difficulty = Difficulty.EASY
var score: int = 0
var timer_remaining: float = 90.0

var question_paths := {
	Difficulty.EASY: [],
	Difficulty.MEDIUM: [],
	Difficulty.HARD: []
}
var used_paths := {
	Difficulty.EASY: [],
	Difficulty.MEDIUM: [],
	Difficulty.HARD: []
}

func _ready():
	question_paths[Difficulty.EASY] = scan_folder("res://questions/easy")
	question_paths[Difficulty.MEDIUM] = scan_folder("res://questions/medium")
	question_paths[Difficulty.HARD] = scan_folder("res://questions/hard")

func scan_folder(path: String) -> Array:
	var files := []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				files.append(path + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return files

func get_random_question_scene(difficulty: Difficulty) -> String:
	var pool = question_paths[difficulty]
	var used = used_paths[difficulty]
	if pool.is_empty():
		push_error("No questions found for difficulty: " + str(difficulty))
		return ""
	if used.size() >= pool.size():
		used.clear()
	var idx = randi() % pool.size()
	while pool[idx] in used:
		idx = randi() % pool.size()
	used.append(pool[idx])
	return pool[idx]

func reset_run():
	score = 0
	timer_remaining = 90.0
	for d in used_paths.keys():
		used_paths[d].clear()
