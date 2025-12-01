extends Node
@onready var sfx: Node = $SFX

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_sfx(sfx_name:String):
	var player:=sfx.get_node(sfx_name) as AudioStreamPlayer
	if not player:
		return
	player.play()

func get_volume(bus_index:int)->float:
	var db:=AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

func set_volume(bus_index:int,v:float)->void:
	var db:=linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index,db)

func set_effect(bus_index:int,effect:int,x:bool):
	AudioServer.set_bus_effect_enabled(bus_index,effect,x)
