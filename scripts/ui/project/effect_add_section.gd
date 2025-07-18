extends FoldableContainer
class_name EffectAddSection

signal effect_selected(effect: Effect)

@export var effects: Effects:
    set(v):
        effects = v
        if effects != null:
            effects.changed.connect(update)
            update()
@export var type: Target.Type

func update():
    for child in $HFlowContainer.get_children():
        child.queue_free()
    for key in effects.keys():
        var effect = effects.g(key)
        if effect.target_types.has(type):
            var button := Button.new()
            button.text = effect.name
            button.focus_mode = Control.FOCUS_ACCESSIBILITY
            button.set_meta("effect", effect)
            button.pressed.connect(func():
                effect_selected.emit(effect)
            )
            $HFlowContainer.add_child(button)
