extends Window

signal save_track(track_clip: TrackClip, id: int)

const TargetRow = preload("uid://dltmtfearhooo")

@export var target_select: OptionButton
@export var project: ProjectTab
@export var targets_container: VBoxContainer
@export var type_select: OptionButton

var track_id = -1

var clip: TrackClip = TrackClip.new():
    set(v):
        clip = v
        $MarginContainer/VBoxContainer/GridContainer/Title.text = clip.name
        update_target_rows()


func open(edit: Variant = null, id: int = -1):
    track_id = id
    clip = TrackClip.new()
    if edit is TrackClip:
        clip.name = edit.name
        clip.targets = edit.targets
        clip.clips = edit.clips
        clip.start = edit.start
        clip.end = edit.end
        clip.render_enable = edit.render_enable
        clip.type = edit.type
        clip = clip
    update_available_targets()
    show()


func close() -> void:
    hide()
    clip = TrackClip.new()
    
    for child in targets_container.get_children():
        child.queue_free()


func update_target_rows():
    for row in targets_container.get_children():
        row.queue_free()
    for target in clip.targets:
        var target_row = TargetRow.instantiate()
        target_row.editable = false
        target_row.set_target_name(target.name)
        target_row.delete.connect(func(_id):
            var id = clip.targets.find(target)
            clip.targets.remove_at(id)
            clip = clip
        )
        targets_container.add_child(target_row)
        target_row.address = target.address


func update_available_targets():
    target_select.clear()
    for device in project.settings.devices:
        for target in device.targets.values():
            if target.type == type_select.selected:
                target_select.add_item(device.name + '/' + target.name)


func _on_save_pressed() -> void:
    emit_signal("save_track", clip, track_id)
    close()


func _on_add_target_pressed() -> void:
    var path = target_select.get_item_text(target_select.get_selected_id()).split('/')
    for device in project.settings.devices:
        if device.name == path[0]:
            clip.targets.append(device.targets.get(path[1]))
    clip = clip


func _on_type_select_item_selected(_index: int) -> void:
    for child in targets_container.get_children():
        child.queue_free()
    clip.targets = []
    update_target_rows()
    update_available_targets()


func _on_title_text_changed(new_text: String):
    clip.name = new_text

func _ready():
    type_select.clear()
    for key in Target.Type.keys():
        type_select.add_item(key)
