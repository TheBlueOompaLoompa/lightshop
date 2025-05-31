extends Control
class_name CursorBucket


func _ready():
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = event.global_position
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE:
			for child in get_children():
				child.queue_free()

func set_children_visibility(vis: bool):
	for child in get_children():
		child.visible = vis
