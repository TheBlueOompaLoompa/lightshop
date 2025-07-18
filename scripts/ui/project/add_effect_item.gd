extends Button

@export var id: int
@export var data: Effect:
    set(v):
        data = v
        text = data.name


func _pressed() -> void:
    get_parent().event.emit("effect_selected", id, data)
