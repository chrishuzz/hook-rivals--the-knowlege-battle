extends Node
## Holds every fish species and rolls which one bites the line.
## Rarer fish have lower "weight" (spawn chance) and higher "difficulty"
## (harder reel-in minigame) but are worth more points.

class FishType:
	var name: String
	var rarity: String
	var weight: float       # relative spawn chance
	var min_kg: float
	var max_kg: float
	var color: Color
	var points: int
	var difficulty: float   # 0..1, higher = harder to reel in
	var bite_delay_min: float
	var bite_delay_max: float

	func _init(p_name: String, p_rarity: String, p_weight: float, p_min_kg: float,
			p_max_kg: float, p_color: Color, p_points: int, p_difficulty: float,
			p_bite_min: float, p_bite_max: float) -> void:
		name = p_name
		rarity = p_rarity
		weight = p_weight
		min_kg = p_min_kg
		max_kg = p_max_kg
		color = p_color
		points = p_points
		difficulty = p_difficulty
		bite_delay_min = p_bite_min
		bite_delay_max = p_bite_max

var fish_types: Array = []

func _ready() -> void:
	fish_types = [
		FishType.new("Anchovy", "Common", 30.0, 0.05, 0.15, Color(0.75, 0.78, 0.8), 5, 0.15, 1.0, 3.0),
		FishType.new("Herring", "Common", 28.0, 0.1, 0.3, Color(0.6, 0.7, 0.85), 8, 0.2, 1.0, 3.0),
		FishType.new("Reef Tuna", "Common", 22.0, 1.0, 4.0, Color(0.2, 0.35, 0.6), 12, 0.3, 1.5, 4.0),
		FishType.new("Mackerel", "Uncommon", 12.0, 0.5, 1.5, Color(0.3, 0.5, 0.55), 20, 0.45, 2.0, 5.0),
		FishType.new("Yellowtail Snapper", "Uncommon", 10.0, 0.8, 2.5, Color(0.95, 0.75, 0.2), 28, 0.5, 2.0, 5.0),
		FishType.new("Swordfish", "Rare", 4.0, 20.0, 60.0, Color(0.45, 0.5, 0.55), 75, 0.75, 3.0, 7.0),
		FishType.new("Blue Marlin", "Rare", 3.0, 30.0, 90.0, Color(0.15, 0.3, 0.65), 90, 0.8, 3.5, 7.5),
		FishType.new("Golden Koi", "Legendary", 1.0, 2.0, 6.0, Color(1.0, 0.84, 0.1), 250, 0.9, 4.0, 9.0),
	]

func get_total_weight() -> float:
	var t := 0.0
	for f in fish_types:
		t += f.weight
	return t

## Weighted random pick — this is where "fish chances depend on variety" lives.
func roll_fish() -> FishType:
	var total := get_total_weight()
	var r := randf() * total
	var acc := 0.0
	for f in fish_types:
		acc += f.weight
		if r <= acc:
			return f
	return fish_types[0]
