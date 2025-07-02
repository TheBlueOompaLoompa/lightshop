extends Resource
class_name Effect

@export var uid: int:
    set(v):
        uid = v
        emit_changed()
@export var name: String:
    set(v):
        name = v
        emit_changed()
@export var target_types: Array[Target.Type]:
    set(v):
        target_types = v
        emit_changed()
@export var parameters: Array[Parameter]:
    set(v):
        parameters = v
        emit_changed()
@export var shader: GLSLSource = GLSLSource.new():
    set(v):
        shader = v
        emit_changed()

func dupe() -> Effect:
    var new: Effect = self.duplicate()
    new.parameters = new.parameters.duplicate_deep(RESOURCE_DEEP_DUPLICATE_ALL)
    return new


func generate_params_glsl() -> String:
    var prefix = "struct " + name.to_pascal_case() + "Params" + " {\n"
    var source = ""
    var postfix = "} " + name.to_camel_case() + "Params; " + "\n// Reference output pixel with PIXEL\n"
    for param in parameters:
        source += "    "
        if param.type == Parameter.Type.Int:
            source += "int " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Float:
            source += "float " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Vector2:
            source += "vec2 " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Vector3:
            source += "vec3 " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Vector4 or param.type == Parameter.Type.Color:
            source += "vec4 " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Bool:
            source += "bool " + param.name + "; // " + param.title
        elif param.type == Parameter.Type.Curve:
            source += "int " + param.name + "_count; // " + param.title + "\n"
            source += "    vec2 " + param.name + "_points[CURVE_POINT_COUNT]; // " + param.title + "\n"
            source += "    vec2 " + param.name + "_tangs[CURVE_POINT_COUNT]; // " + param.title + "\n"
        source += "\n"
    
    return prefix + source + postfix
            
func generate_loader_glsl() -> String:
    var params_var = name.to_camel_case() + "Params"
    
    var prefix = "void " + name.to_pascal_case() + str(uid) + "Load() {\n"
    var source = ""
    var postfix = "\n}"
    
    for param in parameters:
        # pbuf.data[params_i]
        if param.type == Parameter.Type.Int:
            source += params_var + "." + param.name + " = int(pbuf.data[params_i]);\n"
            source += "params_i += 1;\n"
        elif param.type == Parameter.Type.Float:
            source += params_var + "." + param.name + " = uintBitsToFloat(pbuf.data[params_i]);\n"
            source += "params_i += 1;\n"
        elif param.type == Parameter.Type.Vector2:
            source += params_var + "." + param.name + ".x = uintBitsToFloat(pbuf.data[params_i]);\n"
            source += params_var + "." + param.name + ".y = uintBitsToFloat(pbuf.data[params_i+1]);\n"
            source += "params_i += 2;\n"
        elif param.type == Parameter.Type.Vector3:
            source += params_var + "." + param.name + ".x = uintBitsToFloat(pbuf.data[params_i]);\n"
            source += params_var + "." + param.name + ".y = uintBitsToFloat(pbuf.data[params_i+1]);\n"
            source += params_var + "." + param.name + ".z = uintBitsToFloat(pbuf.data[params_i+2]);\n"
            source += "params_i += 3;\n"
        elif param.type == Parameter.Type.Vector4 or param.type == Parameter.Type.Color:
            source += params_var + "." + param.name + ".x = uintBitsToFloat(pbuf.data[params_i]);\n"
            source += params_var + "." + param.name + ".y = uintBitsToFloat(pbuf.data[params_i+1]);\n"
            source += params_var + "." + param.name + ".z = uintBitsToFloat(pbuf.data[params_i+2]);\n"
            source += params_var + "." + param.name + ".w = uintBitsToFloat(pbuf.data[params_i+3]);\n"
            source += "params_i += 4;\n"
        elif param.type == Parameter.Type.Bool:
            source += params_var + "." + param.name + " = pbuf.data[params_i] > 0;\n"
            source += "params_i += 1;\n"
        elif param.type == Parameter.Type.Curve:
            var count: String = params_var + "." + param.name + "_count"
            source += count + " = int(pbuf.data[params_i]);\n"
            source += "params_i += 1;\n"
            source += "for(uint i = 0; i < " + count + "; i++) {\n"
            source += "    " + params_var + "." + param.name + "_points[i].x = uintBitsToFloat(pbuf.data[params_i + i*2]);\n"
            source += "    " + params_var + "." + param.name + "_points[i].y = uintBitsToFloat(pbuf.data[params_i + i*2 + 1]);\n"
            source += "    " + params_var + "." + param.name + "_tangs[i].x = uintBitsToFloat(pbuf.data[params_i + i*2 + " + count + "*2]);\n"
            source += "    " + params_var + "." + param.name + "_tangs[i].y = uintBitsToFloat(pbuf.data[params_i + i*2 + 1 + " + count + "*2]);\n"
            source += "}\n"
            source += "params_i += " + count + "*4;\n"
            
    source = source.substr(0, len(source) - 1)
    return (prefix + source).replace("\n", "\n    ") + postfix


func generate_exec_glsl() -> String:
    var prefix = "void " + name.to_pascal_case() + str(uid) + "Exec() {\n"
    var source = ""
    var postfix = "\n}"
    
    for line in shader.source.split("\n"):
        source += "    " + line + "\n"
    
    return prefix + source + postfix


func generate_call_glsl() -> String:
    var source = "case " + str(uid) + ":\n"
    source += "    " + name.to_pascal_case() + str(uid) + "Load();\n"
    source += "    " + name.to_pascal_case() + str(uid) + "Exec();\n"
    source += "    " + "break;\n"
    
    return source
