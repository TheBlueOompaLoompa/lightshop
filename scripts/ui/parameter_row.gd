extends HBoxContainer
class_name ParameterRow

@export var title_label: Label
@export var input: ParameterInput
@export var parameter: Parameter:
    set(v):
        parameter = v
        input.parameter = parameter
        update()

func update():
    title_label.text = parameter.title
    input.update()
