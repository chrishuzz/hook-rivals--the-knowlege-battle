extends Node3D

func _ready() -> void:
	var fc = $Player/FishingController
	var hud = $HUD
	hud.setup(fc)
