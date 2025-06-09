extends PanelContainer
class_name TrackControl

signal edit
signal delete
signal mouse_over(beat: float)
signal mouse_out
signal clicked
signal clip_clicked(clip: EffectClip)
signal clip_drag_clicked(clip: EffectClip, side: int)

@export var main: Container
@export var title: Label
@export var render_toggle: Button
@export var view_beats: float = 0.0:
    set(v):
        view_beats = v
        main.view_beats = view_beats
@export var scale_px: float = 20.0:
    set(v):
        scale_px = v
        main.scale_px = scale_px
@export var track_clip: TrackClip:
    set(v):
        if track_clip != null:
            track_clip.changed.disconnect(setup)
        track_clip = v
        track_clip.changed.connect(setup)
        if main != null:
            main.track_clip = track_clip

var mouse = false

func _ready() -> void:
    setup()
    track_clip.changed.connect(setup)
    main.track_clip = track_clip


func setup():
    render_toggle.button_pressed = track_clip.render_enable
    title.text = track_clip.name


func _on_render_toggle_toggled(toggled_on: bool) -> void:
    track_clip.render_enable = toggled_on


func _on_edit_pressed():
    emit_signal("edit")


func _on_trash_pressed():
    emit_signal("delete")


func _on_main_mouse_entered():
    mouse = true


func _on_main_mouse_exited():
    emit_signal('mouse_out')
    mouse = false


func _on_main_container_input(event: InputEvent):
    if event is InputEventMouseMotion and mouse:
        var px = event.global_position.x - main.global_position.x
        var b = px / scale_px + view_beats
        emit_signal('mouse_over', b)


func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            emit_signal("clicked")


func _on_main_clip_clicked(clip):
    emit_signal("clip_clicked", clip)


func _on_main_clip_drag_clicked(clip, side):
    emit_signal("clip_drag_clicked", clip, side)
