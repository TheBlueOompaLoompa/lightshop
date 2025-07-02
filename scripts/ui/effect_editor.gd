extends MarginContainer

const EFFECT_EDITOR_ROW = preload("uid://cofluya4qt6qn")
const EFFECT_GRAPH = preload("uid://dx8xcn5b2bmvn")

@export var effects: Effects:
    set(v):
        if effects != null:
            effects.changed.disconnect(_on_effects_changed)
        effects = v
        effects.changed.connect(_on_effects_changed)
        _on_effects_changed()
@export var settings: Settings:
    set(v):
        if settings != null:
            settings.changed.disconnect(_on_settings_changed)
        settings = v
        settings.changed.connect(_on_settings_changed)
        _on_settings_changed()

@export var effects_list: VBoxContainer
@export var graph_box: BoxContainer
@export var effect_config_popup: Window
@export var effect_label: Label
@export var code_edit: CodeEdit
@export var params_text: CodeEdit

var effect_graph_effect: Effect

var editing: Effect:
    set(v):
        if editing != null:
            editing.changed.disconnect(_on_editing_changed)
        editing = v
        if editing != null:
            editing.changed.connect(_on_editing_changed)
            _on_editing_changed()


func _on_editing_changed():
    code_edit.text = editing.shader.source
    params_text.text = editing.generate_params_glsl()


func _on_effects_changed():
    effect_config_popup.effects = effects
    if editing != null:
        editing = effects.g(editing.uid)
    for child in effects_list.get_children():
        child.queue_free()

    for key in effects.keys():
        var effect = effects.g(key)
        var row = EFFECT_EDITOR_ROW.instantiate()
        row.set_title(effect.name)

        row.config.connect(func():
            effect_config_popup.open_effect(effect)
        )
        row.delete.connect(func():
            effects.erase(key)
            effects.emit_changed()
        )
        row.edit.connect(func():
            editing = effect
            #var scene: PackedScene
            #if effect.shader.effect_graph:
                #scene = effect.shader.effect_graph
            #else:
                #scene = EFFECT_GRAPH
            #if graph_box.get_child(0):
                #graph_box.get_child(0).queue_free()
            #graph_box.add_child(scene.instantiate())
            effect_label.text = effect.name
        )

        effects_list.add_child(row)

func _on_settings_changed():
    effect_config_popup.content_scale_factor = settings.ui_scale


func _on_create_effect_pressed() -> void:
    effect_config_popup.new_effect()


func _on_effect_config_popup_save(effect: Effect) -> void:
    effects.s(effect.uid, effect)
    effects.emit_changed()
    effect.emit_changed()


func _on_save_pressed() -> void:
    editing.shader.source = code_edit.text
    effects.s(editing.uid, editing)
    effects.emit_changed()
