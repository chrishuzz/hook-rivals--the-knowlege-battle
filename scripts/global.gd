extends Node


const SCORES_PATH := "user://leaderboard.json"
const SETTINGS_PATH := "user://player.cfg"
const QUESTIONS_PATH := "res://data/questions.json"
const MAX_NAME_LENGTH := 12
const MAX_ENTRIES := 10
const TIER_KEYS := ["easy", "medium", "hard"]
const TIER_NAMES := ["EASY", "MEDIUM", "HARD"]
const TIER_COLORS := [Color("7be07b"), Color("ffd93d"), Color("ff6b6b")]
const SFX_NAMES := ["drop", "splash", "catch", "correct", "wrong", "over", "click"]

var player_name: String = ""
var scores: Array = []          
var last_rank: int = -1         
var questions: Dictionary = {}
var _bags: Array = [[], [], []] 
var _sfx: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # sounds keep playing while a question pauses the game
	_load_settings()
	_load_scores()
	_load_questions()
	for n in SFX_NAMES:
		_sfx[n] = load("res://assets/sfx/%s.wav" % n)


# ---------------------------------------------------------------- player name
func set_player_name(new_name: String) -> void:
	player_name = new_name.strip_edges().left(MAX_NAME_LENGTH)
	var cfg := ConfigFile.new()
	cfg.set_value("player", "name", player_name)
	cfg.save(SETTINGS_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		player_name = str(cfg.get_value("player", "name", ""))


# ---------------------------------------------------------------- leaderboard
func add_score(score: int, words: int, fish: int) -> int:
	## Saves a finished run under the current player name. Returns the 1-based rank, or -1 if outside the top list.
	var rank := 1
	for e in scores:
		if int(e["score"]) >= score:
			rank += 1
	var entry := {"name": player_name, "score": score, "words": words, "fish": fish,
			"date": Time.get_date_string_from_system()}
	scores.insert(rank - 1, entry)
	if scores.size() > MAX_ENTRIES:
		scores.resize(MAX_ENTRIES)
	last_rank = rank if rank <= MAX_ENTRIES else -1
	_save_scores()
	return last_rank


func _load_scores() -> void:
	scores = []
	if not FileAccess.file_exists(SCORES_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SCORES_PATH))
	if parsed is Array:
		scores = parsed
		scores.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))


func _save_scores() -> void:
	var f := FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(scores))


# ---------------------------------------------------------------- questions
func _load_questions() -> void:
	var parsed = null
	if FileAccess.file_exists(QUESTIONS_PATH):
		parsed = JSON.parse_string(FileAccess.get_file_as_string(QUESTIONS_PATH))
	if parsed is Dictionary:
		questions = parsed
		return
	push_warning("questions.json missing (for exports add *.json to the non-resource export filter). Using fallback questions.")
	questions = {
		"easy": [{"q": "What is 1 + 1?", "options": ["1", "2", "3", "4"], "answer": 1}],
		"medium": [{"q": "What is 6 x 7?", "options": ["36", "42", "48", "49"], "answer": 1}],
		"hard": [{"q": "What is 12 x 12?", "options": ["124", "132", "144", "154"], "answer": 2}],
	}


func get_question(tier: int) -> Dictionary:
	if _bags[tier].is_empty():
		_bags[tier] = questions[TIER_KEYS[tier]].duplicate()
		_bags[tier].shuffle()
	return _bags[tier].pop_back()


# ---------------------------------------------------------------- sound
func play_sfx(sfx_name: String) -> void:
	var stream: AudioStream = _sfx.get(sfx_name)
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -6.0
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
