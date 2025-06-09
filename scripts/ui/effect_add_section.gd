extends FoldableContainer

@export var project: Project:
    set(v):
        project = v
        update()
@export var type: Target.Type

func update():
    for effect in project.effects:
        if effect.target_types.has(type):
            var button = Button.new()
            button.text = effect.name
            button.set_meta("effect", effect)
