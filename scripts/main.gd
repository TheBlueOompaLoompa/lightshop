extends Control

@export var tab_container: TabContainer
@export var project_tab: ProjectTab
@export var effect_editor_tab: EffectsEditor
@export var settings_tab: SettingsTab

@export var status_label: RichTextLabel
@export var status_bar: PanelContainer
@export var toggle_status_bar_button: Button
@export var log_window: LogWindow
@export var settings: Settings:
    set(v):
        settings = v
        if settings_tab != null:
            settings_tab.settings = settings
        if project_tab != null:
            project_tab.settings = settings
        if effect_editor_tab != null:
            effect_editor_tab.settings = settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    SQLite.
    get_tree().set_auto_accept_quit(false)
    
    Log.new_line.connect(func(line: String):
        if status_label.text.begins_with('[u]'):
            status_label.text = '[u]' + line + '[/u]'
        else:
            status_label.text = line
    )
    
    var effects_exists = FileAccess.file_exists("user://effects.tres")
    var effects: Effects
    if effects_exists:
        effects = ResourceLoader.load("user://effects.tres")
    else:
        effects = Effects.new()
        ResourceSaver.save(project_tab.effects, "user://effects.tres")
    
    effect_editor_tab.effects = effects
    project_tab.effects = effects
    
    effects.changed.connect(func():
        ResourceSaver.save(project_tab.effects, "user://effects.tres")
    )
    Input.use_accumulated_input = false
    tab_container.set_tab_disabled(1, true)
    apply_settings()


func apply_settings():
    settings = Settings.load_res()
    get_tree().root.content_scale_factor = settings.ui_scale
    GL.update_window_scale.emit(settings.ui_scale)
    settings.changed.connect(func():
        GL.update_window_scale.emit(settings.ui_scale)
    )


func _on_open_project(project_name: String) -> void:
    tab_container.current_tab = 1
    project_tab.name = 'Project ' + project_name
    tab_container.set_tab_disabled(1, false)


func _on_status_label_mouse_entered() -> void:
    status_label.text = '[u]' + status_label.text + '[/u]'


func _on_status_label_mouse_exited() -> void:
    status_label.text = status_label.text.substr(3, status_label.text.length() - 7)


func _on_toggle_status_bar_button_pressed() -> void:
    status_bar.visible = not(status_bar.visible)
    toggle_status_bar_button.icon = preload("uid://r77ie0sib05h") if status_bar.visible else preload("uid://bfi6w8sibnj08")


func _on_status_label_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            log_window.show()
