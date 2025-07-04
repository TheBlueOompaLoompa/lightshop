extends FoldableContainer

func _ready() -> void:
    folding_changed.connect(update)
    foldable_group.expanded.connect(update)

func update(_f: Variant = null):
    if folded:
        size_flags_vertical = Control.SIZE_FILL
    else:
        size_flags_vertical = Control.SIZE_EXPAND_FILL
