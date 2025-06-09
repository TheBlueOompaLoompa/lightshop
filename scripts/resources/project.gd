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
@export var effects: Array[Effect]:
    set(v):
        effects = v
        emit_changed()
@export var follow_playhead: bool = true:
    set(v):
        follow_playhead = v
        emit_changed()

func beats2seconds(beats: float) -> float:
    return 1 / tempo * beats * 60

func seconds2beats(seconds: float) -> float:
    return seconds/60 * tempo
