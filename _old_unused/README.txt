Old duplicate scenes that were lying in the project root. Godot ignores this folder (.gdignore).
player.tscn here had a class_name inside a built-in script, which is a parse error in Godot 4.
The real scenes live in res://scenes/. Safe to delete this folder.
