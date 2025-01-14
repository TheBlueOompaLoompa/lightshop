extends PanelContainer

signal open(id: String)
signal delete(id: String)

var id = null

func set_proj_name(name: String):
    id = name
    $MarginContainer/HBoxContainer/Label.text = name


func _on_open_pressed() -> void:
    if id != null:
        open.emit(id)


func _on_delete_pressed() -> void:
    if id != null:
        delete.emit(id)
        
