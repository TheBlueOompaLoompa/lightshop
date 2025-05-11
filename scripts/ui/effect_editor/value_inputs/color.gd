extends Node

var val: Color = Color()

func _on_color_picker_button_color_changed(color: Color) -> void:
    val = color
