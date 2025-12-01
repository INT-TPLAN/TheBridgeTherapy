extends Node2D

@export var texts: Array[Label]


func _process(delta):
	for j in range(len(texts)):
		texts[j].position += Vector2(0.4 * sin(Time.get_ticks_msec() / 20.0+4*j), 0.4 * cos(Time.get_ticks_msec() / 50.0+4*j))
