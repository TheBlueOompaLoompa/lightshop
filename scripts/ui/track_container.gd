extends Container
class_name TrackContainer

const ClipScene = preload("res://scenes/ui/clip.tscn")

var scale_px: float = 20:
    set(v):
        scale_px = v
        emit_signal("sort_children")

var beats: float = 4:
    set(v):
        beats = v
        emit_signal("sort_children")

var track_clip: TrackClip = null:
    set(v):
        if track_clip != null:
            track_clip.changed.disconnect(_on_track_clip_changed)
        track_clip = v
        

func _on_track_clip_changed():
    pass

func _ready() -> void:
    if track_clip != null:
        track_clip.changed.connect(_on_track_clip_changed)


var spawned_clips: Array[int] = []


func spawn_missing_clips():
    for clip in track_clip.clips:
        var clip_in_view = clip.end > beats and clip.start < beats + size.x/scale_px
        var spawned = spawned_clips.has(clip.get_instance_id())
        if clip_in_view and not(spawned):
            var scene = ClipScene.instantiate()
            scene.clip = clip
            add_child(scene)
            spawned_clips.append(clip.get_instance_id())
        elif not clip_in_view and spawned:
            spawned_clips.remove_at(spawned_clips.find(clip.get_instance_id()))
            for child in get_children():
                if child is ClipControl and child.clip.get_instance_id() == clip.get_instance_id():
                    child.queue_free()
                    
        

func position_children():\
    for child in get_children():
        if child is ClipControl:            
            # Position
            child.position = Vector2i(child.clip.start * scale_px - beats * scale_px, (size.y - 90)/2)
            child.size = Vector2i((child.clip.end - child.clip.start) * scale_px, 90)


func _on_sort_children() -> void:
     spawn_missing_clips()
     position_children()
