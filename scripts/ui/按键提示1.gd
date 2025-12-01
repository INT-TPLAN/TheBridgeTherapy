extends Sprite2D

var hided := false

func _ready():
	visible = false

func _process(delta):
	position += Vector2(0.02 * sin(Time.get_ticks_msec() / 1000.0), 0.02 * cos(Time.get_ticks_msec() / 500.0))

func show_tip():
	hided = false
	modulate.a = 0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 2).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SINE)


func _on_player_player_moved() -> void:
	if not hided:
		hided = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 2).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_SINE)
