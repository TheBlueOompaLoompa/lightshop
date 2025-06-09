extends Resource
class_name Effect

@export var uid: String:
    set(v):
        uid = v
        emit_changed()
@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var target_types: Array[Target.Type]:
    set(v):
        target_types = v
        emit_changed()
@export var parameters: Array[Parameter]:
    set(v):
        parameters = v
        emit_changed()
@export var effect_graph: PackedScene:
    set(v):
        effect_graph = v
        emit_changed()
@export var glsl_cache: String:
    set(v):
        glsl_cache = v
        emit_changed()
