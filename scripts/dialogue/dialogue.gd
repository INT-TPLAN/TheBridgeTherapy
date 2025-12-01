extends Resource
class_name Dialogue

@export_multiline var content: String
@export var can_skip: bool = true
@export var functions: Array[DialogueFunction]
