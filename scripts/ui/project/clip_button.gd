class_name ClipButton extends Button

@export var project: Project

func _delete_clip():
    project.saved_clips.remove_at(self.get_meta("clip_id"))
    project.saved_clips_changed.emit()
