extends Control
@onready var next_icon: Sprite2D = $MarginContainer/NextIcon

@export var text_box: Label
@export var main_dialogue: DialogueGroup

var dialogue_index := 0
var type_tween: Tween

var can_next: bool = true
var is_dialogue_finished: bool = false

var text_target_alpha: float
#音效
var last_sound_index
var random_index

func _ready():
	next_icon.visible = false
	is_dialogue_finished = false
	text_target_alpha = text_box.modulate.a
	text_box.modulate.a = 0
	if main_dialogue:
		display_next_dialogue()


func _process(delta):
	#对话文本摇晃
	text_box.position += Vector2(0.02 * sin(Time.get_ticks_msec() / 1000.0), 0.02 * cos(Time.get_ticks_msec() / 500.0))
	
	#继续图标运动
	next_icon.position += Vector2(0.02 * sin((Time.get_ticks_msec() + 100) / 1000.0), 0.06 * cos(Time.get_ticks_msec() / 500.0))
	next_icon.modulate.a = 0.7 * abs(cos(Time.get_ticks_msec() / 500.0))

	if Input.is_action_just_pressed("click") and can_next:
		display_next_dialogue()

	
func display_next_dialogue():
	next_icon.visible = false

	if dialogue_index < main_dialogue.dialogues.size():
		text_box.modulate.a = text_target_alpha
		var dialogue := main_dialogue.dialogues[dialogue_index]

		if type_tween and type_tween.is_running():
			if dialogue.can_skip:
				text_box.text = ""
				type_tween.kill()
				text_box.text = dialogue.content
				dialogue_index += 1
				next_icon.visible = true
		else:
			text_box.text = ""
			type_tween = get_tree().create_tween()
			var delay: float
			for character in dialogue.content:
				if character in ["，", "。", "？", " "]:
					delay = 0.3
				else:
					delay = 0.1
				
				#音效
				if not last_sound_index:
					last_sound_index = 1
				random_index = randi_range(1, 5)
				# print(random_index)
				while random_index == last_sound_index:
					random_index = randi_range(1, 5)
				last_sound_index = random_index

				type_tween.tween_callback(func(): text_box.text += character; AudioManager.play_sfx("S" + str(random_index))).set_delay(delay)

			type_tween.tween_callback(func(): dialogue_index += 1; if dialogue.functions.size() == 0: next_icon.visible = true)
			process_function(dialogue.functions)
	else:
		if is_dialogue_finished:
			return
		is_dialogue_finished = true
		var alpha_tween = get_tree().create_tween()
		alpha_tween.tween_property(text_box, "modulate:a", 0.0, 1).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_QUART)
		process_function(main_dialogue.end_function)
		
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
			next_icon.visible = false
			var signal_name = i.wait_for_signal_to_continue
			if target_node.has_signal(signal_name):
				can_next = false
				var signal_state = {"done": false}
				var callable = func(): signal_state.done = true
				target_node.connect(signal_name, callable, CONNECT_ONE_SHOT)
				while not signal_state.done:
					# print(1)
					await get_tree().process_frame
				if not is_dialogue_finished:
					can_next = true
					next_icon.visible = true
		else:
			if not is_dialogue_finished:
				next_icon.visible = true

func update_dialogue_group(dg: DialogueGroup):
	main_dialogue = dg
	dialogue_index = 0
	is_dialogue_finished = false
	display_next_dialogue()
