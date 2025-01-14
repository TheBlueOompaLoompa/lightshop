extends Resource
class_name Target

@export var name: String
@export var address: String
@export_range(1, 999999) var leds: int
@export var type: Type
@export var points: PackedVector3Array

enum Type {
    LINEAR,
    SPATIAL
}
