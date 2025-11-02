extends Node3D

@onready var innerMesh : MeshInstance3D = $ButtonInner
@onready var activeMaterial : StandardMaterial3D = preload("res://Resources/Button_Active.tres")
@onready var inactiveMaterial : StandardMaterial3D = preload("res://Resources/Button_Inactive.tres")

func set_active(active: bool):
	if (active):
		innerMesh.set_surface_override_material(0, activeMaterial)
	else:
		innerMesh.set_surface_override_material(0, inactiveMaterial)
