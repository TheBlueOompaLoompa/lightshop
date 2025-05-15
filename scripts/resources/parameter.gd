extends Resource
class_name Parameter

@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var type: Port.Type:
    set(v):
        type = v
        emit_changed()
@export var data = null:
    set(v):
        data = v
        emit_changed()
@export var presets = null:
    set(v):
        presets = v
        emit_changed()
