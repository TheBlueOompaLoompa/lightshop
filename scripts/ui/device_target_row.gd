class_name DeviceTargetRow extends PanelContainer

signal edit
signal delete

@export var label: Label

func _on_edit_pressed() -> void:
    edit.emit()


func _on_delete_pressed() -> void:
    delete.emit()
