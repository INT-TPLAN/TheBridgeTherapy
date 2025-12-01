extends Resource
class_name DialogueGroup
@export_category("事件")
@export var dialogues: Array[Dialogue]
@export_category("结束事件")
@export var end_function: Array[DialogueFunction]