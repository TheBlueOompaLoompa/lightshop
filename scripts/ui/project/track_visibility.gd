extends Window

@export var project_page: MarginContainer
@export var project: Project:
    set(v):
        if project != null:
            project.changed.disconnect(update)
        project = v
        update()
        project.changed.connect(update)

@export var tracks_fold: FoldableContainer
@export var groups_fold: FoldableContainer
@export var tracks_box: VBoxContainer
@export var groups_box: VBoxContainer
@export var hide_icon: Texture2D
@export var show_icon: Texture2D


func update():
    for child in tracks_box.get_children():
        child.queue_free()
    for track in project.tracks:
        var row = HBoxContainer.new()
        var label = Label.new()
        label.text = track.name
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var button = Button.new()
        button.pressed.connect(func():
            track.visible = !track.visible
            project_page.update_tracks()
            update()
        )
        button.icon = show_icon if track.visible else hide_icon
        row.add_child(label)
        row.add_child(button)
        tracks_box.add_child(row)


func _on_tracks_folding_changed(is_folded: bool) -> void:
    if is_folded:
        tracks_fold.size_flags_vertical = Control.SIZE_FILL
    else:
        tracks_fold.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _on_groups_folding_changed(is_folded:  bool) -> void:
    if is_folded:
        groups_fold.size_flags_vertical = Control.SIZE_FILL
    else:
        groups_fold.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _on_close_requested() -> void:
    hide()


func _on_track_visibility_pressed() -> void:
    show()
