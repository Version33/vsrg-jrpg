extends Node

var activeButtonIndex : int = -1
var buttons : Array = []
@onready var Button0 : Node3D = $Button0
@onready var Button1 : Node3D = $Button1
@onready var Button2 : Node3D = $Button2
@onready var Button3 : Node3D = $Button3

func _ready():
	buttons = [
		Button0,
		Button1,
		Button2,
		Button3
	]

func _on_mouse_entered_section(index: int) -> void:
	buttons[index].set_active(true)

func _on_mouse_exited_section(index: int) -> void:
	buttons[index].set_active(false)
