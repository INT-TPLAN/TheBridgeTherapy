extends Sprite2D

func _ready():
	modulate.a = 0

func show_fin():
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 2.5).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_LINEAR)
	await tween.finished
	await get_tree().create_timer(2).timeout
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate:a", 0, 5).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_LINEAR)
	await tween2.finished
	GameManager.load_lvl("lvl1")

func _on_过渡_lvl_2_end_trans_finished() -> void:
	show_fin()
