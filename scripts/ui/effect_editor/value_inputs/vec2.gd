extends Node

var val := Vector2()

func _on_spin_box_value_changed(value: float) -> void:
    val.x = value


func _on_spin_box_2_value_changed(value: float) -> void:
    val.y = value
