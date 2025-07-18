class_name AddEffectPopup extends Window

signal effect_selected(effect: Effect)

@export var list: BaseSearchableList
@export var clip_type: Target.Type:
    set(v):
        clip_type = v
        update_list()
@export var effects: Effects


func update_list():
    list.data = effects.values().filter(func(effect): return effect.target_types.has(clip_type))


func _on_close_requested() -> void:
    hide()


func _on_effect_list_event(event_name: String, _id: int, data: Variant) -> void:
    if event_name == "effect_selected":
        effect_selected.emit(data)
