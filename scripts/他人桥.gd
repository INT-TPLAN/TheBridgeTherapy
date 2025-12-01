extends Area2D
@onready var environment: Node2D = $"../.."


var can_show := false
var showed := false

#音效
var last_sound_index
var random_index

func _ready():
	visible = true
	modulate.a = 0

func set_can_show():
	can_show = true

func dequeue():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5).set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	call_deferred("queue_free")

func _on_mouse_entered() -> void:
	if can_show:
		if not showed:
			#音效
			if not last_sound_index:
				last_sound_index = 1
			random_index = randi_range(1, 5)
			# print(random_index)
			while random_index == last_sound_index:
				random_index = randi_range(1, 5)
			last_sound_index = random_index
			AudioManager.play_sfx("S" + str(random_index))

			environment.call("add_showed_ob")
			showed = true
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1, 1.5).set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
