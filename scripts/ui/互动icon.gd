extends Sprite2D

var hided := false

signal hide_tip

func _ready():
	visible = false

func _process(delta):
	position += Vector2(0.02 * sin(Time.get_ticks_msec() / 1000.0), 0.02 * cos(Time.get_ticks_msec() / 500.0))
	if visible:
		if Input.is_action_pressed("interact"):
			hide_tip.emit()


func show_tip():
	hide_tip.connect(hide_tip_func, CONNECT_ONE_SHOT)
	hided = false
	modulate.a = 0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.6, 2).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SINE)


func hide_tip_func() -> void:
	if not hided:
		hided = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 3).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_SINE)
