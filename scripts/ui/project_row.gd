extends PanelContainer

signal open(id: String)
signal delete(id: String)

var id = null

@export var project: Project

func set_proj_name(_name: String):
    id = _name
    $MarginContainer/HBoxContainer/Label.text = name


func _on_open_pressed() -> void:
    if id != null:
        open.emit(id)


func _on_delete_pressed() -> void:
    if id != null:
        delete.emit(id)
        
