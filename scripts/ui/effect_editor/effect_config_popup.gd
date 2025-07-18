extends Window

signal save(effect: Effect)
signal cancel

@export var effect: Effect:
    set(v):
        effect = v
        update()
@export var effects: Effects
@export var name_edit: LineEdit
@export var linear_check: CheckBox
@export var spatial_check: CheckBox
@export var binary_check: CheckBox
@export var position_check: CheckBox
@export var rotation_check: CheckBox
@export var params_vbox: VBoxContainer

const EFFECT_CONFIG_PARAM_ROW = preload("uid://bxfc3api2u7vt")

func update():
    if effect != null:
        for child in params_vbox.get_children():
            child.queue_free()
        
        name_edit.text = effect.name
        linear_check.button_pressed = effect.target_types.has(Target.Type.LINEAR)
        spatial_check.button_pressed = effect.target_types.has(Target.Type.SPATIAL)
        binary_check.button_pressed = effect.target_types.has(Target.Type.BINARY)
        position_check.button_pressed = effect.target_types.has(Target.Type.POSITION)
        rotation_check.button_pressed = effect.target_types.has(Target.Type.ROTATION)
        
        for param in effect.parameters:
            var row = EFFECT_CONFIG_PARAM_ROW.instantiate()
            row.parameter = param
            row.delete.connect(func():
                effect.parameters.erase(param)
                update()
            )
            params_vbox.add_child(row)


func new_effect():
    effect = Effect.new()
    effect.uid = effects.uid_count
    effects.uid_count += 1
    show()


func open_effect(eff: Effect):
    effect = eff.dupe()
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


func _on_position_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.POSITION)
    else:
        effect.target_types.erase(Target.Type.POSITION)


func _on_rotation_toggled(toggled_on: bool) -> void:
    if toggled_on:
        effect.target_types.push_back(Target.Type.ROTATION)
    else:
        effect.target_types.erase(Target.Type.ROTATION)


func _on_add_parameter_pressed() -> void:
    var param = Parameter.new()
    param.type = Parameter.Type.Int
    param.data = 0
    param.name = ""
    param.title = ""
    effect.parameters.append(param)
    effect.parameters = effect.parameters
    update()
