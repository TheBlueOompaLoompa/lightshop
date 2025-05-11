extends Node

var val := Vector3()

func _on_spin_box_value_changed(value: float) -> void:
    val.x = value


func _on_spin_box_2_value_changed(value: float) -> void:
    val.y = value


func _on_spin_box_3_value_changed(value: float) -> void:
    val.z = value
