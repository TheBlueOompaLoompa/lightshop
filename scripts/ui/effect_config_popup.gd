extends Window

signal save(effect: Effect)
signal cancel

@export var effect: Effect:
    set(v):
        effect = v
        if effect != null:
            name_edit.text = effect.name
            linear_check.button_pressed = effect.target_types.has(Target.Type.LINEAR)
            spatial_check.button_pressed = effect.target_types.has(Target.Type.SPATIAL)
            binary_check.button_pressed = effect.target_types.has(Target.Type.BINARY)
            motion_check.button_pressed = effect.target_types.has(Target.Type.MOTION)

@export var name_edit: LineEdit
@export var linear_check: CheckBox
@export var spatial_check: CheckBox
@export var binary_check: CheckBox
@export var motion_check: CheckBox


func new_effect():
    effect = Effect.new()
    effect.uid = uuid.v4()
    show()


func open_effect(eff: Effect):
    effect = eff.duplicate()
    show()


func _on_cancel_pressed() -> void:
    cancel.emit()
    hide()


func _on_save_pressed() -> void:
    save.emit(effect)
    hide()


func _on_name_text_changed(new_text: String) -> void:
    effect.name = new_text


func _on_linear_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.LINEAR)
    else:
        effect.target_types.erase(Target.Type.LINEAR)


func _on_spatial_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.SPATIAL)
    else:
        effect.target_types.erase(Target.Type.SPATIAL)


func _on_binary_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.BINARY)
    else:
        effect.target_types.erase(Target.Type.BINARY)


func _on_motion_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.MOTION)
    else:
        effect.target_types.erase(Target.Type.MOTION)
