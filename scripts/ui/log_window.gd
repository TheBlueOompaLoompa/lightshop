class_name LogWindow extends Window

@export var label: RichTextLabel

func _ready():
    Log.new_line.connect(_on_new_line)
    GL.listen_window_scale(self)


func _on_new_line(line: String):
    label.append_text(line + '\n')


func _on_close_requested() -> void:
    hide()
