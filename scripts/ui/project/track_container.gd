extends Container
class_name TrackContainer

signal container_input(event: InputEvent)
signal clip_clicked(clip: EffectClip)
signal clip_drag_clicked(clip: EffectClip, side: int)
signal clip_saved(clip: EffectClip)

const CLIP = preload("uid://cwvenjrjscc0a")

var scale_px: float = 20:
    set(v):
        scale_px = v
        emit_signal("sort_children")
var view_beats: float = 0.0:
    set(v):
        view_beats = v
        emit_signal("sort_children")
var track_clip: TrackClip = null:
    set(v):
        if track_clip != null:
            track_clip.changed.disconnect(_on_track_clip_changed)
        track_clip = v
        track_clip.changed.connect(_on_track_clip_changed)


var spawned_clips: Array[int] = []
func update_spawned_clips():
    for clip in track_clip.clips:
        for conn in clip.changed.get_connections():
            clip.changed.disconnect(conn['callable'])
        clip.changed.connect(func():
            update_spawned_clips()
            position_children()
        )
        var clip_in_view = clip.end > view_beats and clip.start < view_beats + size.x/scale_px
        var spawned = spawned_clips.has(clip.get_instance_id())
        # Spawn clips that enter view 
        if clip_in_view and not(spawned):
            var scene = CLIP.instantiate()
            scene.clip = clip
            scene.click.connect(func():
                emit_signal("clip_clicked", clip)
            )
            scene.left_click.connect(func():
                emit_signal('clip_drag_clicked', clip, MOUSE_BUTTON_LEFT)
            )
            scene.right_click.connect(func():
                emit_signal('clip_drag_clicked', clip, MOUSE_BUTTON_RIGHT)
            )
            scene.save_clip.connect(func():
                clip_saved.emit(clip)    
            )
            add_child(scene)
            spawned_clips.append(clip.get_instance_id())
        # Remove clips not in view 
        elif not clip_in_view and spawned:
            spawned_clips.remove_at(spawned_clips.find(clip.get_instance_id()))
            for child in get_children():
                if child is ClipControl and child.clip.get_instance_id() == clip.get_instance_id():
                    child.queue_free()

    # Delete child clips that don't exist
    for child in get_children():
        if child is ClipControl:
            child.clip = child.clip
            if not track_clip.clips.has(child.clip):
                var id = spawned_clips.find(child.clip.get_instance_id())
                if id == -1: continue
                spawned_clips.remove_at(id)
                child.queue_free()

func position_children():
    for child in get_children():
        if child is ClipControl:            
            child.position = Vector2i(int(child.clip.start * scale_px - view_beats * scale_px), int((size.y - 90.0)/2.0))
            child.size = Vector2i((child.clip.end - child.clip.start) * scale_px, 90)


func _on_sort_children() -> void:
    update_spawned_clips()
    position_children()


func _on_track_clip_changed():
    _on_sort_children()


func _input(event):
    emit_signal("container_input", event)
