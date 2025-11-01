extends Node3D

@onready var buttonMesh : MeshInstance3D = $Button2
@onready var activeMaterial : StandardMaterial3D = preload("res://Resources/Button_Active.tres")
@onready var inactiveMaterial : StandardMaterial3D = preload("res://Resources/Button_Inactive.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_mouse_entered() -> void:
	buttonMesh.set_surface_override_material(0, activeMaterial)


func _on_area_3d_mouse_exited() -> void:
	buttonMesh.set_surface_override_material(0, inactiveMaterial)
