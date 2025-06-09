extends PanelContainer
class_name EffectsPane

@export var project: Project
@export var settings: Settings
@export var effects_vbox: VBoxContainer
@export var clip_title_label: Label
@export var add_effect_popup: Window
@export var clip: EffectClip:
    set(v):
        clip = v
        $MarginContainer.visible = clip != null
        if clip != null:
            update()

const effect_row_scene = preload("uid://dx47s1bc16wpt")


func update():
    clip_title_label.text = clip.name
    
    for child in effects_vbox.get_children():
        child.queue_free()

    var effect_index = 0
    for effect in clip.effects:
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
