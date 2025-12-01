extends Node2D

var target_scale: Vector2
var temp_scale: Vector2 = Vector2.ZERO

@export var target_function: DialogueFunctionGroup

signal show_finished

func _ready():
	rotation_degrees = 1
	visible = false
	target_scale = scale
	scale = Vector2.ZERO


func _process(delta):
	var time = Time.get_ticks_msec()
	scale = lerp(scale, temp_scale + Vector2(0.05 * sin((time + 5) / 300.0), 0.05 * cos((time + 4) / 300.0)), delta * 6)

func show_func():
	rotation_degrees = 1
	visible = true

	var tween := create_tween()
	tween.tween_property(self, "temp_scale", target_scale, 1.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SPRING)
	await tween.finished
	show_finished.emit()

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

func update_event_function(x: DialogueFunctionGroup):
	target_function = x

func _on_body_entered(body: Node2D) -> void:
	# print(222)
	if body.is_in_group("Player"):
		AudioManager.play_sfx("Begin")
		process_function(target_function.functions)
