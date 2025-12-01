extends Control
@onready var panel: Panel = $Panel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	panel.visible=get_tree().paused

func _on_button_pressed() -> void:
	GameManager.toggle_pause()
