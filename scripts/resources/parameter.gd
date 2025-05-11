extends Resource
class_name Parameter

@export var name: String:
    set(_v):
        emit_changed()
@export var type: Port.Type:
    set(_v):
        emit_changed()
@export var data = null:
    set(_v):
        emit_changed()
@export var presets = null:
    set(_v):
        emit_changed()
