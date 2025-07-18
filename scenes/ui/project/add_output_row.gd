extends Button

@export var id: int
@export var data: Target:
    set(v):
        data = v
        text = data.path

func _pressed() -> void:
    get_parent().event.emit("selected_output", id, data)
