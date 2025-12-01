extends CharacterBody2D
@onready var face: Node2D = $face

var gravity := 300.0
@export var can_move := false
@export var can_jump := false
@export var can_spawn_death_platform := false

@export var speed := 10.0
@export var jump_force := 50

@export var death_platform: PackedScene

var target_scale: Vector2
var temp_scale: Vector2 = Vector2.ONE * 0.01

signal show_player_finished
signal player_moved
signal move_player_finished

signal hide_all_death_bridge

func _ready():
	rotation_degrees = 1
	visible = false
	target_scale = Vector2.ONE * 1.3
	scale = Vector2.ONE * 0.01


func _process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		velocity.y = 0

	rotation_degrees = 1
	scale = lerp(scale, temp_scale + Vector2(0.05 * sin(Time.get_ticks_msec() / 300.0), 0.05 * cos((Time.get_ticks_msec() + 1) / 300.0)), delta * 6)
	face.position.x = lerp(face.position.x, velocity.x * 0.02, delta * 6)

	movement()

	move_and_slide()

func movement():
	if not can_move:
		return
	var horizontal_input := Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_input * speed

	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		scale.x = target_scale.x * 1.1
		scale.y = target_scale.y * 0.9

	if can_jump:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			AudioManager.play_sfx("Jump")
			scale.x = target_scale.x * 1.2
			scale.y = target_scale.y * 0.8
			velocity.y -= jump_force

	if horizontal_input:
		player_moved.emit()
	
func set_player_can_move(x: bool):
	velocity = Vector2.ZERO
	can_move = x

func set_player_can_jump(x: bool):
	can_jump = x

func set_can_spawn_death_platform(x: bool):
	can_spawn_death_platform = x

func show_player_func():
	rotation_degrees = 1
	visible = true

	position.y -= 100
	velocity.y = 0

	var tween := create_tween()
	tween.tween_property(self, "temp_scale", target_scale, 1.0).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_SPRING)
	await tween.finished
	show_player_finished.emit()

func move_player_func(target_pos: Vector2, res_can_move: bool):
	can_move = false
	velocity = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 2).set_ease(Tween.EaseType.EASE_IN_OUT).set_trans(Tween.TransitionType.TRANS_QUINT)
	await tween.finished
	velocity = Vector2.ZERO
	can_move = res_can_move
	move_player_finished.emit()

func spawn_death_platform():
	var dp = death_platform.instantiate()
	get_tree().current_scene.call_deferred("add_child", dp)

func hide_all_dp_func():
	hide_all_death_bridge.emit()

func _on_死亡边界_body_entered(body: Node2D) -> void:
	AudioManager.play_sfx("Died")
	if can_spawn_death_platform:
		spawn_death_platform()
	move_player_func(Vector2(-248, 0), true)
