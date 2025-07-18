extends PanelContainer

signal add(clip: Clip)

@export var project: Project:
    set(p):
        if p != null and p != project:
            p.saved_clips_changed.connect(update)
        project = p
        update()
@export var linear_box: HFlowContainer
@export var spatial_box: HFlowContainer
@export var binary_box: HFlowContainer
@export var position_box: HFlowContainer
@export var rotation_box: HFlowContainer


func update():
    for child in linear_box.get_children():
        child.queue_free()
    for child in spatial_box.get_children():
        child.queue_free()
    for child in binary_box.get_children():
        child.queue_free()
    for child in position_box.get_children():
        child.queue_free()
    for child in rotation_box.get_children():
        child.queue_free()
    var i = 0
    for clip in project.saved_clips:
        var button = ClipButton.new()
        button.project = project
        button.text = clip.name
        button.focus_mode = Control.FOCUS_ACCESSIBILITY
        button.set_meta("clip_id", i)
        button.pressed.connect(func():
            var new_clip: Clip = clip.duplicate(true)
            for effect in new_clip.effects:
                effect.dupe()
            add.emit(new_clip)
        )
        if clip.type == Target.Type.LINEAR:
            linear_box.add_child(button)
        elif clip.type == Target.Type.SPATIAL:
            spatial_box.add_child(button)
        elif clip.type == Target.Type.BINARY:
            binary_box.add_child(button)
        elif clip.type == Target.Type.POSITION:
            position_box.add_child(button)
        elif clip.type == Target.Type.ROTATION:
            rotation_box.add_child(button)
        var context_menu = ContextMenu.new()
        context_menu.attach_to(button)
        context_menu.add_item("Delete Clip", Callable(button, "_delete_clip"), false, null)
        context_menu.connect_to(button)
        i+=1
