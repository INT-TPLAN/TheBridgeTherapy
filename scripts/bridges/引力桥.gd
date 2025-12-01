extends Sprite2D
@onready var area: Area2D = $Area2D

@export var force_strength: float = 100.0
@export var force_radius: float = 300.0

@export var is_active := false
var target_scale: Vector2

func _ready():
	target_scale = scale
	scale = Vector2.ZERO
	visible = false

func _process(delta: float) -> void:
	if is_active:
		rotate(0.003)

		var bodies = area.get_overlapping_bodies()
		for body in bodies:
			if body is CharacterBody2D:
				apply_force(body)
			
func apply_force(body: CharacterBody2D):
	# print(1)
	var direction_to_center = (area.global_position - body.global_position).normalized()
	var distance_to_center = area.global_position.distance_to(body.global_position)
	var force_magnitude = calculate_force_strength(distance_to_center)
	var force = direction_to_center * force_magnitude
	body.velocity += force * get_physics_process_delta_time()

func calculate_force_strength(distance: float):
	var normalized_distance = distance / force_radius
	return force_strength * (1.0 - normalized_distance)

func show_bridge():
	is_active = true
	scale = Vector2.ZERO
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 2).set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CIRC)

func hide_bridge():
	is_active = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 2).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CIRC)
	await tween.finished
	call_deferred("queue_free")
