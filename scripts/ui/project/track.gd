extends PanelContainer
class_name TrackControl

signal edit
signal delete
signal mouse_over(beat: float)
signal mouse_out
signal clicked
signal clip_clicked(clip: EffectClip)
signal clip_drag_clicked(clip: EffectClip, side: int)
signal clip_saved(clip: EffectClip)

@export var main: Container
@export var title: Label
@export var render_toggle: CheckButton
@export var render_output_enable: CheckBox
@export var preview_output_enable: CheckBox
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
    main.track_clip = track_clip


func setup():
    render_toggle.button_pressed = track_clip.render_enable
    render_output_enable.button_pressed = track_clip.render_output_enable
    preview_output_enable.button_pressed = track_clip.preview_output_enable
    title.text = track_clip.name


func _on_render_toggle_toggled(toggled_on: bool) -> void:
    track_clip.render_enable = toggled_on


func _on_render_output_toggled(toggled_on: bool) -> void:
    track_clip.render_output_enable = toggled_on


func _on_render_preview_toggled(toggled_on: bool) -> void:
    track_clip.preview_output_enable = toggled_on
    

func _on_edit_pressed():
    edit.emit()


func _on_trash_pressed():
    delete.emit()


func _on_main_mouse_entered():
    mouse = true


func _on_main_mouse_exited():
    mouse_out.emit()
    mouse = false


func _on_main_container_input(event: InputEvent):
    if event is InputEventMouseMotion and mouse:
        var px = event.global_position.x - main.global_position.x
        var b = px / scale_px + view_beats
        mouse_over.emit(b)


func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            clicked.emit()


func _on_main_clip_clicked(clip):
    clip_clicked.emit(clip)


func _on_main_clip_drag_clicked(clip, side):
    clip_drag_clicked.emit(clip, side)


func _on_main_clip_saved(clip: EffectClip) -> void:
    clip_saved.emit(clip)
