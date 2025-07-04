class_name ParameterInput extends HBoxContainer

@export var parameter: Parameter:
    set(v):
        parameter = v

const CURVE_EDITOR = preload("uid://cyjwb1bq5qovs")

func vector(count: int, vec: Variant, callback: Callable):
    var node = HBoxContainer.new()
    for i in count:
        var box = SpinBox.new()
        box.min_value = -9999999999
        box.max_value = 9999999999
        box.step = 0.0
        box.value = vec[i]
        box.value_changed.connect(func(val: float):
            callback.call(i, val)
        )
        node.add_child(box)
    return node

func update():
    for child in get_children():
        child.queue_free()
    
    var type = parameter.type
    var node
    if len(parameter.presets.keys()) > 1:
        node = OptionButton.new()
        for preset in parameter.presets.keys():
            node.add_item(preset)
        node.selected = parameter.presets.keys().find(parameter.presets.find_key(parameter.data))
        node.item_selected.connect(func(item):
            if parameter.presets[parameter.presets.keys()[item]] is Resource:
                parameter.data = parameter.presets[parameter.presets.keys()[item]].duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)
            else:
                parameter.data = parameter.presets[parameter.presets.keys()[item]]
        )
    else:
        if type == Parameter.Type.Int:
            node = SpinBox.new()
            node.rounded = true
            node.min_value = -9999999999
            node.max_value = 99999999
            if parameter.data == null: parameter.data = 0
            node.value = parameter.data
            node.value_changed.connect(func(val: float):
                parameter.data = int(val)
            )
        elif type == Parameter.Type.Float:
            node = SpinBox.new()
            node.rounded = false
            node.min_value = -9999999999
            node.max_value = 9999999999
            node.step = 0.0
            if parameter.data == null: parameter.data = 0.0
            node.value = parameter.data
            node.value_changed.connect(func(val: float):
                parameter.data = val
            )
        elif type == Parameter.Type.Color:
            node = ColorPickerButton.new()
            if parameter.data == null: parameter.data = Color.RED
            node.color = parameter.data
            node.color_changed.connect(func(val: Color):
                parameter.data = val
            )
            node.custom_minimum_size.x = 60
        elif type == Parameter.Type.Bool:
            node = CheckBox.new()
            if parameter.data == null: parameter.data = false
            node.button_pressed = parameter.data
            node.toggled.connect(func(val: bool):
                parameter.data = val
            )
            node.custom_minimum_size.x = 60
        elif type == Parameter.Type.Curve:
            node = CURVE_EDITOR.instantiate()
            if not(parameter.data is Curve): parameter.data = Curve.new()
            node.curve = parameter.data
            node.curve.changed.connect(func(): 
                parameter.data = node.curve
            )
        elif type == Parameter.Type.Vector2:
            if not(parameter.data is Vector2): parameter.data = Vector2()
            node = vector(2, parameter.data, func(i, val): 
                parameter.data[i] = val
            )
        elif type == Parameter.Type.Vector3:
            if not(parameter.data is Vector3): parameter.data = Vector3()
            node = vector(3, parameter.data, func(i, val): 
                parameter.data[i] = val
            )
        elif type == Parameter.Type.Vector4:
            if not(parameter.data is Vector4): parameter.data = Vector4()
            node = vector(4, parameter.data, func(i, val): 
                parameter.data[i] = val
            )
    
    node.focus_mode = 0
    add_child(node)
