extends PanelContainer

signal edit(id: int)
signal delete(id: int)

@export var editable = true:
	set(v):
		editable = v
		$Margin/TargetRow/HBoxContainer/Edit.visible = editable
var id = -1

func set_target_name(text: String):
	name = text
	$Margin/TargetRow/Name.text = text

func set_target_id(num: int):
	id = num

func _on_edit_pressed() -> void:
	edit.emit(id)


func _on_delete_pressed() -> void:
	delete.emit(id)
