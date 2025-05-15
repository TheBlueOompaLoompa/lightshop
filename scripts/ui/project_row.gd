extends PanelContainer

signal open(project_name: String)
signal delete(project_name: String)

var project_name = null

@export var project: Project

func set_proj_name(_name: String):
    project_name = _name
    $MarginContainer/HBoxContainer/Label.text = _name


func _on_open_pressed() -> void:
    if project_name != null:
        open.emit(project_name)


func _on_delete_pressed() -> void:
    if project_name != null:
        delete.emit(project_name)
        
