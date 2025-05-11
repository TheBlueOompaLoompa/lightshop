extends Resource
class_name Effect

@export var parameters: Array[Parameter]:
    set(_v):
        emit_changed()
