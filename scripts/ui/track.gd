extends PanelContainer

@onready var main = $HSplit/Main
@onready var title = $HSplit/Side/VBoxContainer/Title
@onready var render_toggle = $HSplit/Side/VBoxContainer/RenderToggle

@export var beats: float = 0.0:
    set(v):
        beats = v
        main.beats = beats
@export var scale_px: float = 20.0:
    set(v):
        scale_px = v
        main.scale_px = scale_px
@export var track_clip: TrackClip:
    set(v):
        track_clip = v
        if main != null:
            main.track_clip = track_clip

func _ready() -> void:
    setup()
    track_clip.connect('changed', setup)
    main.track_clip = track_clip

func setup():
    render_toggle.button_pressed = track_clip.render_enable
    title.text = track_clip.name

func _on_render_toggle_toggled(toggled_on: bool) -> void:
    track_clip.render_enable = toggled_on
