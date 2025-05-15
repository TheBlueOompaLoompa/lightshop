extends Window

signal SaveTrack(track_clip: TrackClip)

const TargetRow = preload("res://scenes/ui/target_row.tscn")

@onready var target_select = $MarginContainer/VBoxContainer/HBox/TargetSelect
@onready var project = $".."
@onready var targets_container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var type_select = $MarginContainer/VBoxContainer/GridContainer/TypeSelect

var clip: TrackClip = TrackClip.new()


func close() -> void:
    hide()
    clip = TrackClip.new()
    $MarginContainer/VBoxContainer/GridContainer/Title.text = ''
    for child in targets_container.get_children():
        child.queue_free()


func _on_save_pressed() -> void:
    clip.name = $MarginContainer/VBoxContainer/GridContainer/Title.text
    for child in targets_container.get_children():
        for target in project.settings.targets:
            if child.name == target.name:
                clip.targets.append(target)
    clip.targets = clip.targets
    project.project.tracks.append(clip)
    project.project.tracks = project.project.tracks
    close()


func _on_visibility_changed() -> void:
    if visible:
        update_available_targets()


func _on_add_target_pressed() -> void:
    var target_row = TargetRow.instantiate()
    target_row.editable = false
    var text = target_select.get_item_text(target_select.get_selected_id())
    target_row.set_target_name(text)
    targets_container.add_child(target_row)
    target_row.delete.connect(func(_id):
        targets_container.get_node(text).queue_free()
    )


func _on_type_select_item_selected(index: int) -> void:
    for child in targets_container.get_children():
        child.queue_free()
    update_available_targets()


func update_available_targets():
    target_select.clear()
    for target in project.settings.targets:
        if target.type == type_select.selected:
            target_select.add_item(target.name)

func _ready():
    type_select.clear()
    for key in Target.Type.keys():
        type_select.add_item(key)
