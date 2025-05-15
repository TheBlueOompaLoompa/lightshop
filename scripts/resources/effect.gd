extends Resource
class_name Effect

@export var parameters: Array[Parameter]:
    set(v):
        parameters = v
        emit_changed()
