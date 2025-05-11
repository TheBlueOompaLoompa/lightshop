extends Resource
class_name Project

@export var name: String:
    set(_v):
        emit_changed()
@export var tempo: float = 120.0:
    set(_v):
        emit_changed()
@export var time: float = 0.0:
    set(_v):
        emit_changed()
@export var offset: float = 0.0:
    set(_v):
        emit_changed()
@export var song_file: String:
    set(_v):
        emit_changed()
@export var tracks: Array[TrackClip]:
    set(_v):
        emit_changed()
@export var effects: Array[Effect]:
    set(_v):
        emit_changed()
