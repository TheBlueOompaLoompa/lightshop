extends MarginContainer

const EFFECT_EDITOR_ROW = preload("uid://cofluya4qt6qn")
const EFFECT_GRAPH = preload("uid://dx8xcn5b2bmvn")

@export var project: Project:
    set(v):
        if project != null:
            project.changed.disconnect(_on_project_changed)
        project = v
        project.changed.connect(_on_project_changed)
        _on_project_changed()
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

var effect_graph_effect: Effect


func _on_project_changed():
    for child in effects_list.get_children():
        child.queue_free()

    var i = 0
    for effect in project.effects:
        var row = EFFECT_EDITOR_ROW.instantiate()
        row.set_title(effect.name)

        row.config.connect(func():
            effect_config_popup.open_effect(effect)
        )
        row.delete.connect(func():
            project.effects.remove_at(i)
            project.emit_changed()
        )
        row.edit.connect(func():
            var scene: PackedScene
            if effect.effect_graph:
                scene = effect.effect_graph
            else:
                scene = EFFECT_GRAPH
            if graph_box.get_child(0):
                graph_box.get_child(0).queue_free()
            graph_box.add_child(scene.instantiate())
            effect_label.text = effect.name
        )

        effects_list.add_child(row)
        i+=1

func _on_settings_changed():
    effect_config_popup.content_scale_factor = settings.ui_scale


func _on_create_effect_pressed() -> void:
    effect_config_popup.new_effect()


func _on_effect_config_popup_save(effect: Effect) -> void:
    var replaced = false
    for i in len(project.effects):
        if project.effects[i].uid == effect.uid:
            project.effects.remove_at(i)
            project.effects.insert(i, effect)
            replaced = true
    if not replaced:
        project.effects.push_front(effect)
    project.emit_changed()


func _on_save_pressed() -> void:
    if effect_graph_effect:
        for i in len(project.effects):
            if project.effects[i].uid == effect_graph_effect.uid:
                project.effects.remove_at(i)
                project.effects.insert(i, effect_graph_effect)
