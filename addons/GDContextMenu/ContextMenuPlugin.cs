#if TOOLS
using Godot;
using System;

[Tool]
public partial class ContextMenuPlugin : EditorPlugin
{
    public override void _EnterTree()
    {
        var script = GD.Load<Script>("uid://qhg58byq8uba");
        var texture = GD.Load<Texture2D>("uid://bw8tliclwpn3d");

        AddCustomType("Context Menu Control", "Control", script, texture);
    }

    public override void _ExitTree()
    {
        RemoveCustomType("Context Menu Control");
    }
}
#endif
