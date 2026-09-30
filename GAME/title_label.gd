@tool
extends Path2D

@export var text: String = "Curved Text":
	set(value):
		text = value
		queue_redraw()

@export var font: Font:
	set(value):
		font = value
		queue_redraw()

@export var font_size: int = 32:
	set(value):
		font_size = value
		queue_redraw()

func _draw():
	if not curve or text.is_empty() or not font:
		return

	var total_length: float = curve.get_baked_length()
	var distance: float = 0.0

	for i in range(text.length()):
		if distance > total_length:
			break # ran out of curve, stop drawing

		var char_str: String = text[i]
		var char_size: Vector2 = font.get_char_size(char_str.unicode_at(0), font_size)

		# Get position and rotation along the Path2D curve
		var pos: Vector2 = curve.sample_baked(distance)
		var next_pos: Vector2 = curve.sample_baked(min(distance + 1.0, total_length))
		var angle: float = (next_pos - pos).angle()

		# Draw the rotated character
		draw_set_transform(pos, angle)
		draw_char(font, Vector2.ZERO, char_str, font_size)

		distance += char_size.x

	# Reset transform so it doesn't leak into any later draw calls
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
