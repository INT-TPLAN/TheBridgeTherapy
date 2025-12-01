extends Node2D
@onready var title: Sprite2D = $Title
@onready var mouse_icon: Sprite2D = $鼠标点击icon

@export var init_event: Array[DialogueFunction]
@export var begin_event: Array[DialogueFunction]

var began := false

func _ready() -> void:
	began = false
	process_function(init_event)

func _process(delta: float) -> void:
	title.position += Vector2(0.02 * sin(Time.get_ticks_msec() / 1000.0), 0.02 * cos(Time.get_ticks_msec() / 500.0))
	mouse_icon.position += Vector2(0.02 * sin((Time.get_ticks_msec() + 100) / 1000.0), 0.06 * cos(Time.get_ticks_msec() / 500.0))
	if not began:
		mouse_icon.modulate.a = 0.7 * abs(cos(Time.get_ticks_msec() / 500.0))
	if Input.is_action_just_pressed("click") and not began:
		AudioManager.play_sfx("Click")
		process_function(begin_event)

		var tween1 = create_tween()
		tween1.tween_property(title, "modulate:a", 0, 1)
		var tween2 = create_tween()
		tween2.tween_property(mouse_icon, "modulate:a", 0, 1)

		began = true

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
					# print(1)
					await get_tree().process_frame
