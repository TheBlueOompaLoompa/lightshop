extends Resource
class_name Project

@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var tempo: float = 120.0:
    set(v):
        tempo = v
        emit_changed()
@export var time: float = 0.0:
    set(v):
        time = v
        emit_changed()
@export var offset: float = 0.0:
    set(v):
        offset = v
        emit_changed()
@export var song_file: String:
    set(v):
        song_file = v
        emit_changed()
@export var tracks: Array[TrackClip]:
    set(v):
        tracks = v
        emit_changed()
# UID: Effect
@export var effects: Dictionary[int, Effect]:
    set(v):
        effects = v
        emit_changed()
@export var follow_playhead: bool = true:
    set(v):
        follow_playhead = v
        emit_changed()
@export var uid_count: int = 0
@export var preview_cam_pos: Vector3 = Vector3.ZERO
@export var preview_cam_rot: Vector2 = Vector2.ZERO
@export var beats := 0.0
@export var view_beats := 0.0
@export var scale_px := 20.0

func beats2seconds(beats: float) -> float:
    return 1 / tempo * beats * 60


func seconds2beats(seconds: float) -> float:
    return seconds/60 * tempo

func compile_effects():
    var renderer_source = FileAccess.open("res://renderer.glsl", FileAccess.READ)
    
    var effects_source = ""
    var run_source = ""
    
    for effect in effects.values():
        var struct_source = effect.generate_params_glsl()
    
