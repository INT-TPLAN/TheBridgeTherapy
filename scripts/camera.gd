extends Camera2D
@onready var bg: Node2D = $bg
@onready var bg_color: ColorRect = $bg/ColorRect

var move_tween: Tween
var target_pos: Vector2

@export var use_mouse_look := false

@export var bg_color_normal: Color = Color.WHITE
@export var bg_color_crt: Color

signal cam_move_finished

func _ready():
	bg.visible = true
	set_bg_color(bg_color_normal)

	target_pos = offset

func _process(delta):
	bg.position = offset + Vector2(-576, -324)
	target_pos += Vector2(0.04 * sin(Time.get_ticks_msec() / 1000.0), 0.04 * cos(Time.get_ticks_msec() / 500.0))
	#鼠标偏移
	var mouse_pos
	if use_mouse_look:
		mouse_pos = get_local_mouse_position()
	else:
		mouse_pos = Vector2.ZERO
	var mouse_offset_res = mouse_pos - offset
	mouse_offset_res.x = clamp(mouse_offset_res.x, -400, 400)
	mouse_offset_res.y = clamp(mouse_offset_res.y, -200, 50)
	
	offset = lerp(offset, target_pos + mouse_offset_res, delta * 3)
	#position = lerp(position, mouse_pos + Vector2(0, -64), delta * 6)

func set_cam_pos(pos: Vector2):
	target_pos = pos
	offset = target_pos

func move_cam_to(pos: Vector2, duration: float, ease_type := Tween.EaseType.EASE_IN_OUT, trans_type := Tween.TransitionType.TRANS_QUINT):
	if move_tween and move_tween.is_running():
		move_tween.kill()
	move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "target_pos", pos, duration).set_ease(ease_type).set_trans(trans_type)
	await move_tween.finished
	cam_move_finished.emit()

func set_use_mouse_look(x: bool):
	use_mouse_look = x

func set_bg_color(x: Color):
	bg_color.color = x

func _on_过渡_show_crt() -> void:
	set_bg_color(bg_color_crt)
