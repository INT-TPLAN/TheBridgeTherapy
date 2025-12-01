extends Node

@export var current_lvl: Node
@export var current_lvl_index := 1
@export_category("lvls")
const lvl1 = preload("uid://ckjw7fayq0e0w")
const lvl2 = preload("uid://bjgrh0e0xqwsu")

const CONFIG_PATH := "user://config.ini"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_lvl("lvl1")
	load_config()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused

func toggle_pause():
	get_tree().paused = !get_tree().paused

func load_lvl(lvl: String):
	if current_lvl:
		current_lvl.queue_free()
		await get_tree().process_frame
	if lvl == "lvl1":
		current_lvl_index = 1
		current_lvl = lvl1.instantiate()
		get_tree().current_scene.add_child(current_lvl)
	elif lvl == "lvl2":
		current_lvl_index = 2
		current_lvl = lvl2.instantiate()
		get_tree().current_scene.add_child(current_lvl)

func save_config():
	var config := ConfigFile.new()

	config.set_value("audio", "BGM", AudioManager.get_volume(1))
	config.set_value("audio", "SFX", AudioManager.get_volume(2))

	config.save(CONFIG_PATH)

func load_config():
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)

	AudioManager.set_volume(1, config.get_value("audio", "BGM", 1.0))
	AudioManager.set_volume(2, config.get_value("audio", "SFX", 1.0))