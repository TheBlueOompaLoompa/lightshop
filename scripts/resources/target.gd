extends Resource
class_name Target

@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var address: String:
    set(v):
        address = v        
        emit_changed()
@export_range(1, 999999) var leds: int:
    set(v):
        leds = v
        emit_changed()
@export var type: Type:
    set(v):
        type = v
        emit_changed()
@export var points: PackedVector3Array:
    set(v):
        points = v
        emit_changed()
@export var gpu_layers: int = 4:
    set(v):
        gpu_layers = v
        emit_changed()
@export var framerate: float = 30:
    set(v):
        framerate = v
        emit_changed()
@export var renderer_source: String:
    set(v):
        renderer_source = v
        emit_changed()

enum Type {
    LINEAR,
    SPATIAL,
    BINARY,
    MOTION,
}
