extends HBoxContainer

signal delete

@export var parameter: Parameter:
    set(v):
        parameter = v
        $ParameterInput.parameter = parameter
        $ParameterInput.update()
        $Name.text = parameter.name


func _on_delete_pressed() -> void:
    delete.emit()


func _on_name_text_submitted(new_text:  String) -> void:
    parameter.name = new_text
