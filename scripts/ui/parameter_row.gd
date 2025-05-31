extends HBoxContainer
class_name ParameterRow

@export var title_label: Label
@export var hbox: HBoxContainer
@export var parameter: Parameter:
	set(v):
		parameter = v
		update()

func update():
	title_label.text = parameter.name

	for child in hbox.get_children():
		child.queue_free()
	
	var type = parameter.type
	if type == Parameter.Type.Int:
		var node = SpinBox.new()
		node.rounded = true
		node.min_value = -9999999999
		node.max_value = 9999999999
		node.value_changed.connect(func(val: float):
			parameter.data = int(val)
		)
		hbox.add_child(node)
	elif type == Parameter.Type.Float:
		var node = SpinBox.new()
		node.rounded = false
		node.min_value = -9999999999
		node.max_value = 9999999999
		node.step = 0.0
		node.value_changed.connect(func(val: float):
			parameter.data = val
		)
		hbox.add_child(node)
