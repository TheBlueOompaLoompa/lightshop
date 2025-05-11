extends Resource
class_name Target

@export var name: String:
    set(_v):
        emit_changed()
@export var address: String:
    set(_v):
        emit_changed()
@export_range(1, 999999) var leds: int:
    set(_v):
        emit_changed()
@export var type: Type:
    set(_v):
        emit_changed()
@export var points: PackedVector3Array:
    set(_v):
        emit_changed()

enum Type {
    LINEAR,
    SPATIAL,
    BINARY,
    ROTATION,
}
