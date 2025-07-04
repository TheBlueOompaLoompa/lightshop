extends Resource
class_name Project

signal name_changed
signal tempo_changed
signal time_changed
signal offset_changed
signal song_file_changed
signal tracks_changed
signal effects_changed
signal saved_clips_changed

@export var name: String:
    set(v):
        name = v
        name_changed.emit()
        emit_changed()
@export var tempo: float = 120.0:
    set(v):
        tempo = v
        tempo_changed.emit()
        emit_changed()
@export var time: float = 0.0:
    set(v):
        time = v
        time_changed.emit()
        emit_changed()
@export var offset: float = 0.0:
    set(v):
        offset = v
        offset_changed.emit()
        emit_changed()
@export var song_file: String:
    set(v):
        song_file = v
        song_file_changed.emit()
        emit_changed()
@export var tracks: Array[TrackClip]:
    set(v):
        tracks = v
        tracks_changed.emit()
        emit_changed()
# UID: Effect
@export var effects: Dictionary[int, Effect]:
    set(v):
        effects = v
        effects_changed.emit()
        emit_changed()
@export var follow_playhead: bool = true:
    set(v):
        follow_playhead = v
        emit_changed()
@export var saved_clips: Array[EffectClip] = []:
    set(v):
        saved_clips = v
        saved_clips_changed.emit()
@export var uid_count: int = 0
@export var preview_cam_pos: Vector3 = Vector3.ZERO
@export var preview_cam_rot: Vector2 = Vector2.ZERO
@export var beats := 0.0
@export var view_beats := 0.0
@export var scale_px := 20.0

func beats2seconds(b: float) -> float:
    return 1 / tempo * b * 60


func seconds2beats(seconds: float) -> float:
    return seconds/60 * tempo
