extends PanelContainer

@export var curve: Curve
@export var resolution = 2
@export var line: Line2D
@export var controls: Control

const CURVE_POINT = preload("uid://b4tammbv0ni2g")


func update_points():
    for control in controls.get_children():
        control.queue_free()
    for i in curve.point_count:
        var pos = curve.get_point_position(i)
        pos.y = 1.0 - pos.y
        var control = CURVE_POINT.instantiate()
        control.moved.connect(func(p):
            var temp = Vector2(p)
            temp.y = size.y - temp.y
            curve.set_point_offset(i, temp.x/size.x)
            curve.set_point_value(i, temp.y/size.y)
            update_line()
        )
        control.right_tan.connect(func(tangent):
            curve.set_point_right_tangent(i, tangent)
            update_line()
        )
        control.right_arm.rotation = -atan(curve.get_point_right_tangent(i))
        control.left_tan.connect(func(tangent):
            curve.set_point_left_tangent(i, tangent)
            update_line()
        )
        control.delete.connect(func():
            curve.remove_point(i)
            update_editor()
        )
        controls.add_child(control)
        control.position = (pos * size.x)

func update_line():
    line.clear_points()
    for x in size.x:
        line.add_point(Vector2(x, size.y - curve.sample(x/size.x)*size.y))

func update_editor():
    update_line()
    update_points()

func _ready() -> void:
    if curve != null:
        update_editor()


func _on_gui_input(event:  InputEvent) -> void:
    if curve == null: return
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and curve.point_count < 5:
            curve.add_point(Vector2(event.position.x/size.x, 1.0 - event.position.y/size.y))
            update_editor()
