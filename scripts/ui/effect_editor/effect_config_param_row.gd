extends PanelContainer

signal delete

@export var parameter: Parameter:
    set(v):
        parameter = v
        update()
@export var name_input: LineEdit
@export var title_input: LineEdit
@export var type_input: OptionButton
@export var param_input: ParameterInput
@export var presets_panel: PanelContainer
@export var preset_box: VBoxContainer

const PRESET_ROW = preload("uid://c8rwsekyjj7wh")

func update():
    type_input.clear()
    for type in Parameter.Type:
        type_input.add_item(type)
    type_input.selected = parameter.type
    name_input.text = parameter.name
    title_input.text = parameter.title
    param_input.parameter = parameter
    param_input.update()
    for child in preset_box.get_children():
        child.queue_free()
    for preset in parameter.presets.keys():
        var p = Parameter.new()
        p.name = preset
        p.type = parameter.type
        p.data = parameter.presets.get(preset)
        
        var row = PRESET_ROW.instantiate()
        row.parameter = p
        row.delete.connect(func():
            parameter.presets.erase(preset)
            update()
        )
        p.changed.connect(func():
            if p.name != preset:
                parameter.presets.erase(preset)
                parameter.presets.set(p.name, p.data)
                update()
            else:
                parameter.presets.set(p.name, p.data)
        )
        preset_box.add_child(row)
    

func _on_delete_pressed() -> void:
    delete.emit()


func _on_name_text_changed(new_text:  String) -> void:
    parameter.name = new_text


func _on_title_text_changed(new_text:  String) -> void:
    parameter.title = new_text


func _on_type_item_selected(index:  int) -> void:
    parameter.type = index as Parameter.Type
    parameter.data = null
    param_input.update()


func _on_presets_pressed() -> void:
    presets_panel.visible = not presets_panel.visible


func _on_new_preset_pressed() -> void:
    parameter.presets.set("Untitled", parameter.data)
    update()
