extends CanvasLayer

@onready var prompt_label: Label = $Prompt
@onready var power_bar: ProgressBar = $PowerBar
@onready var reel_panel: Control = $ReelPanel
@onready var tension_bar: ProgressBar = $ReelPanel/TensionBar
@onready var target_zone: ColorRect = $ReelPanel/TensionBar/TargetZone
@onready var progress_bar: ProgressBar = $ReelPanel/ProgressBar
@onready var catch_log: RichTextLabel = $CatchLog
@onready var message_label: Label = $Message

var catches := {}
var total_points := 0

func setup(fc: Node) -> void:
	fc.connect("state_changed", Callable(self, "_on_state_changed"))
	fc.connect("cast_power_changed", Callable(self, "_on_power_changed"))
	fc.connect("bite_started", Callable(self, "_on_bite_started"))
	fc.connect("reel_updated", Callable(self, "_on_reel_updated"))
	fc.connect("fish_caught", Callable(self, "_on_fish_caught"))
	fc.connect("fish_escaped", Callable(self, "_on_fish_escaped"))
	power_bar.visible = false
	reel_panel.visible = false
	message_label.visible = false
	_refresh_log()

func _on_state_changed(state: int) -> void:
	match state:
		0: # IDLE
			prompt_label.text = "Hold [Left Click] to cast your line"
			power_bar.visible = false
			reel_panel.visible = false
		1: # CHARGING
			prompt_label.text = "Release to cast!"
			power_bar.visible = true
		2: # CASTING
			prompt_label.text = "Casting..."
			power_bar.visible = false
		3: # WAITING
			prompt_label.text = "Waiting for a bite..."
		4: # BITE
			prompt_label.text = "CLICK NOW!"
		5: # REELING
			prompt_label.text = "Hold [Left Click] to reel — keep the tension in the green zone!"
			reel_panel.visible = true

func _on_power_changed(ratio: float) -> void:
	power_bar.value = ratio * 100.0

func _on_bite_started() -> void:
	message_label.visible = false

func _on_reel_updated(tension: float, progress: float, target_center: float, target_width: float) -> void:
	tension_bar.value = tension * 100.0
	progress_bar.value = progress * 100.0
	target_zone.anchor_left = clamp(target_center - target_width, 0.0, 1.0)
	target_zone.anchor_right = clamp(target_center + target_width, 0.0, 1.0)

func _on_fish_caught(fish_name: String, weight_kg: float, rarity: String, points: int) -> void:
	catches[fish_name] = catches.get(fish_name, 0) + 1
	total_points += points
	_show_message("Caught a %s (%.1f kg, %s)! +%d pts" % [fish_name, weight_kg, rarity, points])
	_refresh_log()

func _on_fish_escaped(reason: String) -> void:
	var msg := "The fish got away..."
	if reason == "line_snapped":
		msg = "The line snapped! Fish got away."
	_show_message(msg)

func _show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	var t := get_tree().create_timer(2.5)
	t.connect("timeout", Callable(self, "_hide_message"))

func _hide_message() -> void:
	message_label.visible = false

func _refresh_log() -> void:
	var text := "[b]Catch Log[/b] (Total: %d pts)\n" % total_points
	for k in catches.keys():
		text += "%s x%d\n" % [k, catches[k]]
	catch_log.text = text
