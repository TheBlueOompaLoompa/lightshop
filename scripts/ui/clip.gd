extends PanelContainer
class_name ClipControl

@export var clip: Clip:
    set(v):
        clip = v
        update_name()

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
    var style = load("res://clip_panel_style.tres").duplicate(true)
    add_theme_stylebox_override("panel", style)

func _ready():
    update_name()
    
func update_name():
    $LabelContainer/Label.text = clip.name
