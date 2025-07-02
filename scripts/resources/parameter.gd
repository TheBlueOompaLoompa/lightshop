extends Resource
class_name Parameter

@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var title: String:
    set(v):
        title = v
        emit_changed()
@export var type: Type:
    set(v):
        type = v
        emit_changed()
@export var data: Variant:
    set(v):
        data = v
        emit_changed()
@export var presets: Dictionary[String, Variant] = {}:
    set(v):
        presets = v
        emit_changed()

enum Type {
    Int,
    Float,
    Vector2,
    Vector3,
    Vector4,
    Color,
    Bool,
    Curve
}
