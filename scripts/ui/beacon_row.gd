class_name BeaconRow extends PanelContainer

signal add_device_pressed

@export var ip_label: Label


func _on_button_pressed() -> void:
    add_device_pressed.emit()
