extends EffectNode
class_name BuiltEffect

@export var graph_scene: String
@export var code_cache: String
@export var cache_time: String

## Returns code [b]STRING on success[/b] or [b]NULL on error[/b]
func compile():
    var scene: PackedScene = load(graph_scene)
    var graph: EffectGraph = scene.instantiate()
    
    return graph.compile()
