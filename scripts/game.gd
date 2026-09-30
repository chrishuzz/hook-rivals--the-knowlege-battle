extends Node2D


const SCREEN_W := 480.0
const WATER_Y := 72.0
const ROUND_TIME := 80.0            
const WORD_TIME_BONUS := 5.0        
const BOAT_SPEED := 130.0
const HOOK_DOWN_SPEED := 200.0
const HOOK_UP_SPEED := 160.0
const HOOK_FLOOR_Y := 238.0
const LANES := [110.0, 138.0, 166.0, 194.0, 222.0]
const MAX_FISH := 12

const LETTER_POINTS := 2
const QUESTION_POINTS := [10, 20, 30]      
const WRONG_ANSWER_PENALTY := 5            
const WRONG_FISH_PENALTY := 15             
const TIER_STARTS := [0, 5, 12]            
const SPEED_BONUS := [0.0, 12.0, 25.0]     
const WORDS := [
	["ARCHIPELAGO", "SUNRISE", "ECOSYSTEM", "VESSEL", "CURRENT", "CRUSTACEAN", "COASTLINE", "SEAGRASS"],
["PREDATOR", "REEF", "MAMMAL", "PACIFIC", "MOLLUSK", "GEM", "CEPHALOPOD"],
["CETACEAN", "DECAPOD", "TENTACLE", "KELP", "MARITIME", "REPTILE", "MYTH"]
]

enum HookState { IDLE, DROPPING, REELING }

@onready var player: Player = $Player
@onready var fishes: Node2D = $Fishes
@onready var popup: QuestionPopup = $QuestionPopup
@onready var game_over: GameOverPanel = $GameOver
@onready var name_label: Label = $HUD/NameLabel
@onready var score_label: Label = $HUD/ScoreLabel
@onready var words_label: Label = $HUD/WordsLabel
@onready var time_label: Label = $HUD/TimeLabel
@onready var level_label: Label = $HUD/LevelLabel
@onready var word_label: RichTextLabel = $HUD/WordLabel
@onready var hint_label: Label = $HUD/HintLabel
@onready var banner_label: Label = $HUD/BannerLabel

var fish_scene: PackedScene = load("res://scenes/fish.tscn")
var hook_state := HookState.IDLE
var caught: Fish = null
var playing := true
var time_left := ROUND_TIME
var score := 0
var words_done := 0
var fish_caught := 0
var questions_asked := 0
var word := ""
var letter_index := 0
var spawn_timer := 0.5
var _splashed := false
var _last_tier := 0
var _banner_tween: Tween


func _ready() -> void:
	randomize()
	name_label.text = Global.player_name
	banner_label.modulate.a = 0.0
	_setup_touch_controls()
	_new_word()
	for i in 9:
		_spawn_fish(true)
	_update_hud()
	var t := create_tween()
	t.tween_interval(6.0)
	t.tween_property(hint_label, "modulate:a", 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not playing or get_tree().paused:
		return
	var drop := event.is_action_pressed("ui_down") or event.is_action_pressed("ui_accept")
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		drop = true
	if drop:
		_start_drop()


func _process(delta: float) -> void:
	if not playing:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_update_hud()
		_end_game()
		return
	_move_boat(delta)
	_update_hook(delta)
	_update_fish(delta)
	_update_hud()



func _move_boat(delta: float) -> void:
	var dir := 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir += 1.0
	player.position.x = clampf(player.position.x + dir * BOAT_SPEED * delta, 20.0, SCREEN_W - 20.0)


func _start_drop() -> void:
	if not playing or hook_state != HookState.IDLE:
		return
	hook_state = HookState.DROPPING
	_splashed = false
	Global.play_sfx("drop")


func _update_hook(delta: float) -> void:
	match hook_state:
		HookState.DROPPING:
			player.set_depth(player.depth + HOOK_DOWN_SPEED * delta)
			if not _splashed and player.hook.global_position.y > WATER_Y:
				_splashed = true
				Global.play_sfx("splash")
			var rect := player.hook_rect()
			for f in fishes.get_children():
				var fish := f as Fish
				if fish != null and not fish.is_caught and rect.intersects(fish.get_rect()):
					caught = fish
					fish.is_caught = true
					hook_state = HookState.REELING
					Global.play_sfx("catch")
					break
			if player.depth >= HOOK_FLOOR_Y - player.rod_tip.global_position.y:
				hook_state = HookState.REELING
		HookState.REELING:
			player.set_depth(player.depth - HOOK_UP_SPEED * delta)
			if caught != null:
				caught.global_position = player.hook.global_position + Vector2(0, 6)
			if player.depth <= 0.0:
				player.set_depth(0.0)
				hook_state = HookState.IDLE
				if caught != null:
					_on_fish_landed()



func _on_fish_landed() -> void:
	var fish := caught
	var tier := _tier()
	fish_caught += 1
	get_tree().paused = true
	popup.ask(Global.get_question(tier), tier, fish.letter)
	var correct: bool = await popup.answered
	get_tree().paused = false
	questions_asked += 1
	caught = null
	_resolve_catch(fish, correct, tier)


func _resolve_catch(fish: Fish, answer_ok: bool, tier: int) -> void:
	var letter_ok := fish.letter == word[letter_index]
	var change := 0
	var msg := ""
	var col := Color.WHITE
	if letter_ok and answer_ok:
		change = LETTER_POINTS + QUESTION_POINTS[tier]
		letter_index += 1
		msg = "CORRECT! +%d" % change
		col = Color("7be07b")
		Global.play_sfx("correct")
	elif letter_ok:
		change = -WRONG_ANSWER_PENALTY
		msg = "WRONG ANSWER - FISH ESCAPED! %d" % change
		col = Color("ff6b6b")
		Global.play_sfx("wrong")
	elif answer_ok:
		msg = "RIGHT ANSWER, BUT WRONG FISH!"
		col = Color("ffd93d")
		Global.play_sfx("click")
	else:
		change = -WRONG_FISH_PENALTY
		msg = "WRONG FISH + WRONG ANSWER! %d" % change
		col = Color("ff6b6b")
		Global.play_sfx("wrong")
	score = maxi(0, score + change)
	fish.queue_free()
	_show_banner(msg, col)

	if letter_ok and answer_ok and letter_index >= word.length():
		_word_complete()
	if _tier() > _last_tier:
		_last_tier = _tier()
		_show_banner("LEVEL UP: %s QUESTIONS!" % Global.TIER_NAMES[_last_tier], Global.TIER_COLORS[_last_tier])
	_refresh_word()
	_update_hud()


func _word_complete() -> void:
	var bonus := clampi(roundi(time_left / ROUND_TIME * 20.0), 5, 20)
	score += bonus
	words_done += 1
	time_left += WORD_TIME_BONUS
	_show_banner("WORD DONE! +%d BONUS +%dS" % [bonus, int(WORD_TIME_BONUS)], Color("ffe14d"))
	_new_word()


func _tier() -> int:
	if questions_asked >= TIER_STARTS[2]:
		return 2
	if questions_asked >= TIER_STARTS[1]:
		return 1
	return 0


func _new_word() -> void:
	var pool: Array = WORDS[_tier()].duplicate()
	pool.erase(word)
	word = pool.pick_random()
	letter_index = 0
	_refresh_word()


func _update_fish(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(0.5, 1.0)
		_spawn_fish()
	for f in fishes.get_children():
		var fish := f as Fish
		if not fish.is_caught and (fish.position.x < -40.0 or fish.position.x > SCREEN_W + 40.0):
			fish.queue_free()


func _spawn_fish(scatter := false) -> void:
	if fishes.get_child_count() >= MAX_FISH:
		return
	var lane: float = LANES.pick_random()
	var dir := 1 if randf() < 0.5 else -1
	var x := randf_range(30.0, SCREEN_W - 30.0) if scatter else (-20.0 if dir > 0 else SCREEN_W + 20.0)
	var needed := word[letter_index]
	var has_needed := false
	for f in fishes.get_children():
		var other := f as Fish
		if absf(other.position.y - lane) < 12.0 and absf(other.position.x - x) < 48.0:
			return                                  
		if other.letter == needed and not other.is_caught:
			has_needed = true
	var letter := needed                             
	if has_needed:
		var roll := randf()
		if roll < 0.30:
			letter = needed
		elif roll < 0.65:
			letter = word[randi() % word.length()]
		else:
			letter = char(65 + randi() % 26)
	var fish: Fish = fish_scene.instantiate()
	fish.position = Vector2(x, lane)
	fishes.add_child(fish)
	fish.setup(letter, randi() % 5, randf_range(32.0, 48.0) + SPEED_BONUS[_tier()], dir)



func _end_game() -> void:
	playing = false
	Global.play_sfx("over")
	var rank := Global.add_score(score, words_done, fish_caught)
	game_over.show_results(score, words_done, fish_caught, rank)



func _update_hud() -> void:
	score_label.text = "SCORE %d" % score
	words_label.text = "WORDS %d" % words_done
	time_label.text = "TIME %d" % ceili(time_left)
	time_label.add_theme_color_override("font_color", Color("ff6b6b") if time_left < 10.0 else Color.WHITE)
	var t := _tier()
	level_label.text = Global.TIER_NAMES[t]
	level_label.add_theme_color_override("font_color", Global.TIER_COLORS[t])


func _refresh_word() -> void:
	var s := "[center]"
	for i in word.length():
		var c := word[i]
		if i < letter_index:
			s += "[color=#ffe14d]%s[/color] " % c
		elif i == letter_index:
			s += "[color=#ffffff][u]%s[/u][/color] " % c
		else:
			s += "[color=#8ea1c4]%s[/color] " % c
	word_label.text = s + "[/center]"


func _show_banner(text: String, col: Color) -> void:
	if _banner_tween:
		_banner_tween.kill()
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", col)
	banner_label.modulate.a = 1.0
	_banner_tween = create_tween()
	_banner_tween.tween_interval(1.4)
	_banner_tween.tween_property(banner_label, "modulate:a", 0.0, 0.4)


func _setup_touch_controls() -> void:
	if not DisplayServer.is_touchscreen_available():
		return
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	for def in [["<", 8.0, "ui_left"], [">", 60.0, "ui_right"]]:
		var b := Button.new()
		b.text = def[0]
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(def[1], 226.0)
		b.size = Vector2(44, 36)
		var action: String = def[2]
		b.button_down.connect(func(): Input.action_press(action))
		b.button_up.connect(func(): Input.action_release(action))
		layer.add_child(b)
	var hook_button := Button.new()
	hook_button.text = "HOOK"
	hook_button.focus_mode = Control.FOCUS_NONE
	hook_button.position = Vector2(412.0, 226.0)
	hook_button.size = Vector2(60, 36)
	hook_button.pressed.connect(_start_drop)
	layer.add_child(hook_button)
