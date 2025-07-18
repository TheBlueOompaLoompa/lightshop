extends Node

signal update_window_scale(scale: float)
var scale = 1.0


func _ready() -> void:
    update_window_scale.connect(func(p_scale):
        scale = p_scale
    )


func listen_window_scale(window: Window):
    window.content_scale_factor = scale
    update_window_scale.connect(func(p_scale):
        window.content_scale_factor = p_scale
    )


## Param input format: [code]Array[Dict[String (param name), Port.Type]][/code]
func gen_parameter_comment(input_params: Array[Dictionary], output_params: Array[Dictionary]) -> String:
    var out: String = "// PARAMETERS "
    JSON.stringify({
        'input': input_params,
        'output': output_params
    })
    
    return out

func parse_parameter_comment(comment: String) -> Dictionary:
    var raw = comment.replace("// PARAMETERS ", "").replace("\n", "")
    return JSON.parse_string(raw)
    
