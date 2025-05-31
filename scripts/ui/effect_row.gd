extends HBoxContainer
class_name EffectRowControl

signal move_up
signal move_down
signal delete_effect

@export var title_label: Label
@export var parameters_container: VBoxContainer
@export var effect: Effect:
	set(v):
		effect = v
		update()

const parameter_row_scene = preload("uid://ccir2nbfxepiw")

func update():
	title_label.text = effect.name
	for child in parameters_container.get_children():
		child.queue_free()
	
	for parameter in effect.parameters:
		var row = parameter_row_scene.instantiate()
		row.parameter = parameter
		parameters_container.add_child(row)

func _on_up_pressed():
	emit_signal("move_up")


func _on_down_pressed():
	emit_signal("move_down")


func _on_delete_pressed():
	emit_signal("delete_effect")
