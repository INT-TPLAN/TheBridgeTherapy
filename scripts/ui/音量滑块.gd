extends HSlider

@export var bus:=1

func _ready() -> void:
	value=AudioManager.get_volume(bus)
	value_changed.connect(func(v:float):
		AudioManager.set_volume(bus,v)
		GameManager.save_config()
	)
 
