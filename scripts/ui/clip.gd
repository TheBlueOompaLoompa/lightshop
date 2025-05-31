extends PanelContainer
class_name ClipControl

signal click
signal left_click
signal right_click

@export var clip: Clip:
	set(v):
		clip = v
		clip.changed.connect(update)
		update()

var unselected_style = preload("uid://d0x2u5pjggxrk")
var selected_style = preload("uid://wasdno3fdw3c")

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	add_theme_stylebox_override("panel", unselected_style)
	clip.changed.connect(update)

func update():
	update_name()
	if clip.timing:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		$LeftDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$RightDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		$LeftDrag.mouse_filter = Control.MOUSE_FILTER_STOP
		$RightDrag.mouse_filter = Control.MOUSE_FILTER_STOP
	
	remove_theme_stylebox_override("panel")
	if clip.selected:
		add_theme_stylebox_override("panel", selected_style.duplicate())
	else:
		add_theme_stylebox_override("panel", unselected_style.duplicate())
	
func update_name():
	$LabelContainerContainer/LabelContainer/Label.text = clip.name

var has_mouse = false
var left_drag_has_mouse = false
var right_drag_has_mouse = false
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if has_mouse:
				emit_signal("click")
			elif left_drag_has_mouse:
				emit_signal("left_click")
			elif right_drag_has_mouse:
				emit_signal("right_click")


func _on_mouse_entered():
	has_mouse = true


func _on_mouse_exited():
	has_mouse = false


func _on_left_drag_mouse_entered():
	left_drag_has_mouse = true


func _on_left_drag_mouse_exited():
	left_drag_has_mouse = false


func _on_right_drag_mouse_entered():
	right_drag_has_mouse = true


func _on_right_drag_mouse_exited():
	right_drag_has_mouse = false
