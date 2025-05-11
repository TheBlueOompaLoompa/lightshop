extends Node

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
    
