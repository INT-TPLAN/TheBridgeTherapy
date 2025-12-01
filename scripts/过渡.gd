extends ColorRect
@onready var crt: ColorRect = $"../crt"
@onready var thoughts: Node2D = $"../../thoughts"
@onready var camera: Camera2D = $"../../Camera2D"

@export var can_trans := false
@export var time_to_trans: float = 3
var trans_progress: float = 0

signal has_transed
signal show_crt
signal lvl2_end_trans_finished

func _ready():
	color = Color.BLACK
	color.a = 0
	has_transed.connect(lvl1_end_trans_func, CONNECT_ONE_SHOT)
	if GameManager.current_lvl_index == 1:
		begin_trans_func()

func _process(delta):
	if can_trans:
		color = Color.BLACK
		color.a = lerp(0.0, 1.0, trans_progress / time_to_trans)
		if Input.is_action_pressed("interact"):
			trans_progress += delta
		else:
			if trans_progress > 0:
				trans_progress -= delta
			else:
				trans_progress = 0
	if trans_progress >= time_to_trans + 1:
		has_transed.emit()

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

func set_can_trans(x: bool):
	can_trans = x


func lvl1_end_trans_func():
	can_trans = false
	color = Color.WHITE
	AudioManager.play_sfx("Flash")
	await get_tree().create_timer(0.1).timeout
	AudioManager.set_effect(1, 0, true)
	color.a = 0
	crt.visible = true
	show_crt.emit()
	thoughts.show()
	camera.call("set_use_mouse_look", true)
	await get_tree().create_timer(10).timeout
	color = Color.WHITE
	AudioManager.play_sfx("Flash")
	await get_tree().create_timer(0.1).timeout
	AudioManager.set_effect(1, 0, false)
	GameManager.load_lvl("lvl2")

func lvl2_end_trans_func():
	color = Color.WHITE
	color.a = 0
	var tween = create_tween()
	tween.tween_property(self, "color:a", 1, 2.5).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_LINEAR)
	await tween.finished
	lvl2_end_trans_finished.emit()

func begin_trans_func():
	color = Color.WHITE
	color.a = 1
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0, 2).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_LINEAR)
