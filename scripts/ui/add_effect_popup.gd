extends Window

signal effect_selected(effect: Effect)

@export var effects: Effects:
    set(v):
        effects = v
        if effects != null:
            linear_fold.effects = effects
            spatial_fold.effects = effects
            binary_fold.effects = effects
            motion_fold.effects = effects
@export var linear_fold: EffectAddSection
@export var spatial_fold: EffectAddSection
@export var binary_fold: EffectAddSection
@export var motion_fold: EffectAddSection

func _on_cancel_pressed():
    hide()


func _on_linear_fold_effect_selected(effect: Effect) -> void:
    effect_selected.emit(effect)


func _on_spatial_fold_effect_selected(effect: Effect) -> void:
    effect_selected.emit(effect)


func _on_binary_fold_effect_selected(effect: Effect) -> void:
    effect_selected.emit(effect)


func _on_motion_fold_effect_selected(effect: Effect) -> void:
    effect_selected.emit(effect)
