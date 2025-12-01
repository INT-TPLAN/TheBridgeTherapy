extends Node2D
var player: CharacterBody2D


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	player.connect("hide_all_death_bridge", hide_bridge, CONNECT_ONE_SHOT)
	show_bridge()

func show_bridge():
	visible = true
	position = player.position
	position.y += 100

	var tween = create_tween()
	tween.tween_property(self, "position:y", 130, 2.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_QUINT)

func hide_bridge():
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", 400, 2.0).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_QUINT)
	await tween.finished
	call_deferred("queue_free")