extends MarginContainer

@export var Db: DB

@export var audio_player: AudioStreamPlayer
@export var minutes_node: SpinBox
@export var seconds_node: SpinBox


var project: Project

func reset_ui():
    audio_player.stream = AudioStreamOggVorbis.load_from_file(project.song_file)


func _on_open_project(id: String) -> void:
    var db = Db.getdb()
    
    db.query_with_bindings('SELECT * FROM %s WHERE name = ?;' % Db.PROJECTS_TABLE, [id])
    print(db.query_result[0])
    var queried_project: Dictionary = db.query_result[0]
    #project = Project.deserialize(queried_project)
    
    reset_ui()
    
    Db.release()

var pause_time = 0.0
var play_time = 0.0
var stopped = true

func _on_play_pressed() -> void:
    if audio_player.playing:
        audio_player.stop()
    else:
        if stopped:
            audio_player.play(play_time)
            stopped = false
        else:
            audio_player.play(pause_time)
            play_time = pause_time


func _on_stop_pressed() -> void:
    if not(audio_player.playing):
        play_time = 0
        pause_time = 0
    else:
        stopped = true
        pause_time = play_time
        audio_player.stop()

var minutes_focused = false
var seconds_focused = false

func _process(_d) -> void:
    if audio_player.playing:
        pause_time = audio_player.get_playback_position()
    if !minutes_focused:
        minutes_node.value = floori(pause_time / 60)
    if !seconds_focused:
        seconds_node.value = fmod(pause_time, 60)


func _on_minutes_value_changed(value: float) -> void:
    if minutes_focused:
        play_time = value * 60 + seconds_node.value
        pause_time = play_time
        audio_player.seek(play_time)


func _on_seconds_value_changed(value: float) -> void:
    if seconds_focused:
        play_time = minutes_node.value * 60 + value
        pause_time = play_time
        audio_player.seek(play_time)


func _ready():
    minutes_node.get_line_edit().connect('focus_entered', func():
        minutes_focused = true
    )
    minutes_node.get_line_edit().connect('focus_exited', func():
        minutes_focused = false
    )
    seconds_node.get_line_edit().connect('focus_entered', func():
        seconds_focused = true
    )
    seconds_node.get_line_edit().connect('focus_exited', func():
        seconds_focused = false
    )
