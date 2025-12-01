extends Node2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var target_pos: Vector2
var is_building_bridge := false
var building_progress: float = 0
@export var time_to_build: float = 5
@export var end_func: Array[DialogueFunction]

signal show_bridge_finished
signal bridge_built

func _ready():
	target_pos = position
	visible = false
	collision_shape_2d.disabled = true
	bridge_built.connect(bridge_built_func, CONNECT_ONE_SHOT)

func _process(delta):
	if is_building_bridge:
		position.y = lerp(position.y, (lerp(target_pos.y + 110, target_pos.y, building_progress / time_to_build)), delta * 6)
		if Input.is_action_pressed("interact"):
			building_progress += delta
		else:
			building_progress = 0
		
		if building_progress >= time_to_build:
			bridge_built.emit()

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

func show_bridge():
	visible = true
	collision_shape_2d.disabled = false
	position.y += 200

	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 2.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_QUINT)
	await tween.finished
	show_bridge_finished.emit()

func hide_bridge():
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos + Vector2(0, 300), 2.0).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_QUINT)
	await tween.finished

func set_is_building_bridge(x: bool):
	is_building_bridge = x

func set_bridge_visible(x: bool):
	if x:
		modulate.a = 1
	else:
		modulate.a = 0

func bridge_built_func():
	AudioManager.play_sfx("Built")
	is_building_bridge = false
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 1.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CIRC)
	process_function(end_func)
