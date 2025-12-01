extends Node2D

@onready var o3: Area2D = $他人桥3 / Area
@onready var o2: Area2D = $他人桥2 / Area
@onready var o1: Area2D = $他人桥1 / Area

@onready var flash_obj: AnimatedSprite2D = $闪屏
@onready var flash: AnimationPlayer = $闪屏 / AnimationPlayer


@export var showed_ob_count: int = 0
@export var all_ob_showed_event: Array[DialogueFunction]

signal all_ob_showed
signal hide_bubble

func _ready():
	all_ob_showed.connect(all_ob_showed_func, CONNECT_ONE_SHOT)
	flash_obj.visible = false
	flash.active = false

func _process(delta):
	if showed_ob_count >= 3:
		all_ob_showed.emit()

func all_ob_showed_func():
	process_function(all_ob_showed_event)

func add_showed_ob():
	showed_ob_count += 1

func set_others_bridge_can_show():
	o1.call("set_can_show")
	o2.call("set_can_show")
	o3.call("set_can_show")

func dequeue_all_obs():
	o1.call("dequeue")
	o2.call("dequeue")
	o3.call("dequeue")

func flash_func():
	flash_obj.visible = true

	flash.active = true
	flash.play("flash")
	await flash.animation_finished
	hide_bubble.emit()
	flash_obj.visible = false
	flash_obj.call_deferred("queue_free")


func process_function(DFs: Array[DialogueFunction]):
	for i in DFs:
		var target_node
		if get_node(i.target_path):
			target_node = get_node(i.target_path)
		else:
			return
		if target_node.has_method(i.function_name):
			if i.function_arguments.size() == 0:
				target_node.call(i.function_name)
			else:
				target_node.callv(i.function_name, i.function_arguments)

		if i.wait_for_signal_to_continue:
			var signal_name = i.wait_for_signal_to_continue
			if target_node.has_signal(signal_name):
				var signal_state = {"done": false}
				var callable = func(): signal_state.done = true
				target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
				while not signal_state.done:
					await get_tree().process_frame

func _on_心想_do_flash() -> void:
	flash_func()
