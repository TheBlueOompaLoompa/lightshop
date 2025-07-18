extends PanelContainer
class_name EffectsPane

signal effect_param_changed

@export var effects: Effects:
    set(v):
        effects = v
        $AddEffectPopup.effects = effects
@export var settings: Settings:
    set(v):
        settings = v
        $AddEffectPopup.content_scale_factor = settings.ui_scale
@export var effects_vbox: VBoxContainer
@export var clip_title_line: LineEdit
@export var add_effect_popup: AddEffectPopup
@export var clip: EffectClip:
    set(v):
        if clip != null:
            clip.changed.disconnect(update)
        clip = v
        $MarginContainer.visible = clip != null
        if clip != null:
            clip.changed.connect(update)
            update()

const effect_row_scene = preload("uid://dx47s1bc16wpt")


func update():
    add_effect_popup.clip_type = clip.type
    if not clip_title_line.is_editing():
        clip_title_line.text = clip.name
    for child in effects_vbox.get_children():
        child.queue_free()

    var effect_index = 0
    for effect in clip.effects:
        for param in effect.parameters:
            param.changed.connect(effect_param_changed.emit)
        var row = effect_row_scene.instantiate()
        row.effect = effect
        row.move_up.connect(func():
            var temp = clip.effects[effect_index]
            clip.effects.remove_at(effect_index)
            clip.effects.insert(maxi(effect_index-1, 0), temp)
            update()
        )
        row.move_down.connect(func():
            var temp = clip.effects[effect_index]
            clip.effects.remove_at(effect_index)
            clip.effects.insert(mini(effect_index+1, clip.effects.size()), temp)
            update()
        )
        row.delete_effect.connect(func():
            clip.effects.remove_at(effect_index)
            update()
        )
        effects_vbox.add_child(row)
        effect_index+=1


func _on_add_pressed():
    add_effect_popup.show()


func _on_add_effect_popup_effect_selected(effect: Effect) -> void:
    var new = effect.dupe()
    clip.effects.append(new)
    clip.emit_changed()
    update()


var layer_mix_types = [
    "Alpha",
    "Add",
    "Multiply",
]


func _on_add_layer_pressed() -> void:
    var layer = Effect.new()
    layer.name = "Layer"
    layer.uid = -1
    var type = Parameter.new()
    type.name = "mix"
    type.title = "Mix"
    type.type = Parameter.Type.Int
    type.data = 0
    var i = 0
    for mix in layer_mix_types:
        type.presets.set(mix, i)
        i += 1
    layer.parameters.append(type)
    clip.effects.append(layer)
    clip.emit_changed()
    update()


func _on_clip_title_text_changed(new_text:  String) -> void:
    clip.name = new_text
