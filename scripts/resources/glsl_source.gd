class_name GLSLSource extends Resource

@export var source: String:
    set(v):
        source = v
        emit_changed()
@export var effect_graph: PackedScene:
    set(v):
        effect_graph = v
        emit_changed()
