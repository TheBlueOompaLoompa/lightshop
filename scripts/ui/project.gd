extends MarginContainer

@export var Db: DB

@export var audio_player: AudioStreamPlayer
@export var minutes_node: SpinBox
@export var seconds_node: SpinBox

@export var tracks_container: VBoxContainer
@export var ticks: PanelContainer
@export var settings: Settings:
    set(v):
        settings = v
        settings.changed.connect(_on_settings_changed)
        _on_settings_changed()

const TrackScene = preload("res://scenes/ui/track.tscn") 

var project: Project = null:
    set(v):
        if project != null:
            project.changed.disconnect(_on_project_changed)
        project = v
        project.changed.connect(_on_project_changed)
var pause_time = 0.0
var play_time = 0.0
var stopped = true
var scale_px = 20.0:
    set(v):
        scale_px = v
        for track in tracks_container.get_children():
            track.scale_px = scale_px
        ticks.scale_px = scale_px
var beats = 0.0:
    set(v):
        beats = v
        ticks.beats = beats
var view_beats = 0.0:
    set(v):
        view_beats = v
        ticks.view_beats = view_beats
        for track in tracks_container.get_children():
            track.beats = view_beats


func _on_project_changed():
    for child in tracks_container.get_children():
        child.queue_free()
    for track in project.tracks:
        var scene = TrackScene.instantiate()
        scene.track_clip = track
        tracks_container.add_child(scene)
    ticks.track_count = project.tracks.size()


func reset_ui():
    audio_player.stream = AudioStreamOggVorbis.load_from_file(project.song_file)        


func _on_open_project(project_name: String) -> void:
    project = ResourceLoader.load('user://projects/'+project_name+'.res')
    reset_ui()


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
    view_beats = project.seconds2beats(play_time)

var minutes_focused = false
var seconds_focused = false

func _process(_d) -> void:
    if project == null: return
    if audio_player.playing:
        beats = project.seconds2beats(audio_player.get_playback_position() if audio_player.playing else pause_time)
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


func _on_tracks_gui_input(event: InputEvent) -> void:
    var dir = -1 if settings.invert_scroll else 1
    if event.is_action_pressed("zoom_scroll_up"):
        scale_px += dir
    elif event.is_action_pressed("zoom_scroll_down"):
        scale_px -= dir
    elif event.is_action_pressed("pan_scroll_left"):
        view_beats -= dir / 10.0
    elif event.is_action_pressed("pan_scroll_right"):
        view_beats += dir / 10.0
    scale_px = minf(maxf(10.0, scale_px), 100.0)
    view_beats = maxf(0.0, view_beats)


func _on_new_track_pressed() -> void:
    $TrackWindow.show()


func _on_settings_changed():
    $TrackWindow.content_scale_factor = settings.ui_scale
