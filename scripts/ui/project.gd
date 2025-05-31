extends MarginContainer

@export var audio_player: AudioStreamPlayer
@export var minutes_node: SpinBox
@export var seconds_node: SpinBox

@export var effects_pane: EffectsPane
@export var tracks_container: VBoxContainer
@export var ticks: PanelContainer
@export var division_label: Label
@export var division_slider: HSlider
@export var cursor_bucket: CursorBucket
@export var settings: Settings:
	set(v):
		settings = v
		settings.changed.connect(_on_settings_changed)
		_on_settings_changed()

const TrackScene = preload("uid://dti6q07tc44qm")

@export var project: Project = null:
	set(v):
		if project != null:
			project.changed.disconnect(_on_project_changed)
		project = v
		project.changed.connect(_on_project_changed)
var pause_time = 0.0
var play_time = 0.0
var stopped = true
var selected_clip: Clip = null
var selected_clip_track: TrackControl = null
var dragging_clip: Clip = null
var drag_direction: int = -1
var dragging_track: TrackControl = null
var scale_px = 20.0:
	set(v):
		scale_px = v
		for track in tracks_container.get_children():
			track.scale_px = scale_px
		ticks.scale_px = scale_px
var division = 2.0:
	set(v):
		division = v
		ticks.division = v
var beats = 0.0:
	set(v):
		beats = v
		ticks.beats = beats
var view_beats = 0.0:
	set(v):
		view_beats = v
		ticks.view_beats = view_beats
		for track in tracks_container.get_children():
			track.view_beats = view_beats

func update_tracks():
	for child in tracks_container.get_children():
		child.queue_free()
	var i = 0
	for track in project.tracks:
		var track_scene = TrackScene.instantiate()
		track_scene.track_clip = track
		track_scene.edit.connect(func():
			$TrackWindow.open(track, i)
		)
		i+=1
		track_scene.delete.connect(func():
			var id = project.tracks.find(track)
			project.tracks.remove_at(id)
			project.tracks = project.tracks
		)
		track_scene.mouse_over.connect(func(b: float):
			if cursor_bucket.get_child_count() == 0: return
			var clip_scene = cursor_bucket.get_child(0)
			if clip_scene is ClipControl:
				set_cursor_bucket_visible(false)
				var clip = clip_scene.clip
				if not track.clips.has(clip):
					track.clips.append(clip)
				var snap = snappedf(b, 1/division)
				clip.start = snap
				var next_clip = track.find_next_clip_after(clip)
				clip.end = clip.start + clip.length
				if next_clip != null: clip.end = minf(clip.end, next_clip.start)
				clip.timing = true
				track.clips = track.clips
		)
		track_scene.mouse_out.connect(func():
			if cursor_bucket.get_child_count() == 0: return
			var clip_scene = cursor_bucket.get_child(0)
			if clip_scene is ClipControl:
				set_cursor_bucket_visible(true)
				var clip = clip_scene.clip
				if track.clips.has(clip):
					var idx = track.clips.find(clip)
					track.clips.remove_at(idx)
					track.clips = track.clips

		)
		track_scene.clicked.connect(func():
			if cursor_bucket.get_child_count() == 0: return
			var clip_scene = cursor_bucket.get_child(0)
			if clip_scene is ClipControl:
				var clip = clip_scene.clip
				if track.clips.has(clip):
					clip.timing = false
					clear_cursor_bucket()
		)
		track_scene.clip_clicked.connect(func(clip):
			if selected_clip != null:
				selected_clip.selected = false
			selected_clip = clip
			selected_clip.selected = true
			effects_pane.clip = selected_clip
			selected_clip_track = track_scene
		)
		track_scene.clip_drag_clicked.connect(func(clip, side):
			if dragging_clip != null:
				dragging_clip.timing = false
			dragging_clip = clip
			drag_direction = side
			dragging_track = track_scene
		)
		tracks_container.add_child(track_scene)
	ticks.track_count = project.tracks.size()


func _on_project_changed():
	update_tracks()


func reset_ui():
	audio_player.stream = AudioStreamOggVorbis.load_from_file(project.song_file)
	update_tracks()


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
	beats = view_beats

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
	if dragging_clip != null:
		var left_offset = tracks_container.global_position.x + dragging_track.main.global_position.x
		var b = view_beats + (get_global_mouse_position().x - left_offset)/scale_px
		b = snappedf(b, 1/division) if division > 0 else b
		b = maxf(b, view_beats)
		var over_other = false
		
		for clip in dragging_track.track_clip.clips:
			if clip != dragging_clip:
				if clip.start < b and clip.end > b:
					over_other = true
				if drag_direction == MOUSE_BUTTON_LEFT:
					if b <= clip.start and dragging_clip.end >= clip.end:
						over_other = true
				else:
					if dragging_clip.start <= clip.start and b >= clip.end:
						over_other = true
		if not over_other:
			if drag_direction == MOUSE_BUTTON_LEFT:
				if b < dragging_clip.end:
					dragging_clip.start = b
			else:
				if b > dragging_clip.start:
					dragging_clip.end = b
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_clip = null


func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_DELETE:
				var idx = selected_clip_track.track_clip.clips.find(selected_clip)
				selected_clip_track.track_clip.clips.remove_at(idx)
				selected_clip_track.track_clip.clips = selected_clip_track.track_clip.clips


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
	var shift_pressed = Input.is_key_pressed(KEY_SHIFT)
	var scroll_up = event.is_action_pressed("zoom_scroll_up")
	var scroll_down = event.is_action_pressed("zoom_scroll_down")
	var scroll_left = event.is_action_pressed("pan_scroll_left")
	var scroll_right = event.is_action_pressed("pan_scroll_right")
	
	if not shift_pressed:
		if scroll_up:
			scale_px += dir
		elif scroll_down:
			scale_px -= dir
	else:
		if scroll_left or scroll_up:
			view_beats -= dir / 10.0
		elif scroll_right or scroll_down:
			view_beats += dir / 10.0
	scale_px = minf(maxf(10.0, scale_px), 100.0)
	view_beats = maxf(0.0, view_beats)


func _on_new_track_pressed() -> void:
	$TrackWindow.open()


func _on_settings_changed():
	$TrackWindow.content_scale_factor = settings.ui_scale


func _on_ticks_playhead_scroll(bts: float) -> void:
	if audio_player.playing:
		view_beats += bts


func _on_ticks_retime(b: float) -> void:
	beats = b
	var seconds = project.beats2seconds(b)
	if audio_player.playing:
		audio_player.seek(seconds)
	else:
		play_time = seconds
		pause_time = seconds


func _on_menu_bar_file_pressed(text):
	if text == 'Save':
		ResourceSaver.save(project, 'user://projects/'+project.name+'.res')
	elif text == 'Quit':
		get_tree().quit()


func _on_track_window_save_track(track_clip, id):
	if id != -1:
		project.tracks[id] = track_clip
	else:
		project.tracks.append(track_clip)
	update_tracks()


func _on_division_value_changed(value):
	division_label.text = '1/'+str(int(value))
	if division > 0:
		division = value


func _on_snapping_toggled(toggled_on):
	if toggled_on:
		division = division_slider.value
	else:
		division = 0.0


const ClipScene = preload("res://scenes/ui/clip.tscn")


func add_to_cursor_bucket(node: Control):
	cursor_bucket.add_child(node)


func clear_cursor_bucket():
	for child in cursor_bucket.get_children():
		child.queue_free()


func set_cursor_bucket_visible(vis: bool):
	cursor_bucket.set_children_visibility(vis)


func _on_clip_button_pressed():
	var clip_scene = ClipScene.instantiate()
	var clip = EffectClip.new()
	clip.name = 'example'
	clip.start = 0
	clip.end = 4
	clip.length = 4
	clip.type = Target.Type.LINEAR
	clip_scene.clip = clip
	add_to_cursor_bucket(clip_scene)
	set_cursor_bucket_visible(true)
