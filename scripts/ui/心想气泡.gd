extends Sprite2D
@onready var bridge: Sprite2D = $桥1加深

var show_bubble := false
var show_bridge := false
var show_bridge_progress: float = 0
@export var time_to_show_bridge: float = 5
@export var end_func: Array[DialogueFunction]

signal bridge_showed
signal do_flash

func _ready():
	modulate.a = 0
	bridge.modulate.a = 0
	show_bridge_progress = 0

	bridge_showed.connect(bridge_show_func, CONNECT_ONE_SHOT)

func _process(delta):
	if show_bridge:
		bridge.position += Vector2(0.02 * sin(Time.get_ticks_msec() / 1000.0), 0.02 * cos(Time.get_ticks_msec() / 500.0))
		modulate.a = 1
	
	if show_bubble and not show_bridge:
		if Input.is_action_pressed("interact"):
			modulate.a = lerp(modulate.a, 1.0, show_bridge_progress / (time_to_show_bridge * 4))
			show_bridge_progress += delta
		else:
			modulate.a = lerp(modulate.a, 0.0, delta * 3)
			show_bridge_progress = 0
	
	if show_bridge_progress >= time_to_show_bridge:
		show_bridge = true
		bridge_showed.emit()

func bridge_show_func():
	bridge.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(bridge, "modulate:a", 1, 2).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SINE)
	await tween.finished
	await get_tree().create_timer(2).timeout
	AudioManager.play_sfx("Died")
	do_flash.emit()


func show_bubble_func():
	show_bubble = true

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

func _on_environment_hide_bubble() -> void:
	visible = false
	await get_tree().create_timer(2).timeout
	process_function(end_func)
	call_deferred("queue_free")
