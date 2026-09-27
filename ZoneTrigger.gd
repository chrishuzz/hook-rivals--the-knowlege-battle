extends Area2D
class_name ZoneTriggerArea   

@export var target_zone_key: String        
@export var target_scene: String           
@export var entry_y: float = 40.0          

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hook"):
		ZoneManager.transition_to(target_zone_key, target_scene, entry_y, area)
