extends Control


func _ready():
    propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        global_position = event.global_position
