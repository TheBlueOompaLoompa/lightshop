extends Control

@export var panel: Panel

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
    var style = load("res://clip_panel_style.tres").duplicate(true)
    panel.add_theme_stylebox_override("panel", style)
