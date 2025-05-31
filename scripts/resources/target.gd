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

enum Type {
	LINEAR,
	SPATIAL,
	BINARY,
	ROTATION,
}
