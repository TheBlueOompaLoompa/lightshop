extends PanelContainer
class_name EffectEditorRow

signal delete
signal config
signal edit
signal insert

@export var name_label: Label

func set_title(text: String):
    name_label.text = text


func _on_trash_pressed() -> void:
    delete.emit()


func _on_config_pressed() -> void:
    config.emit()


func _on_edit_pressed() -> void:
    edit.emit()


func _on_insert_pressed() -> void:
    insert.emit()
