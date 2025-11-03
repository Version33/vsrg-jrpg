class_name LaneIndicator
extends MeshInstance3D

@export var lane_index: int = 0
@export var active_color: Color = Color(1.0, 1.0, 1.0, 0.9)
@export var inactive_color: Color = Color(0.5, 0.5, 0.5, 0.7)
@export var flash_duration: float = 0.1

var is_active: bool = false
var flash_timer: float = 0.0

func _ready():
	_update_material()

func _process(delta: float):
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			is_active = false
			_update_material()

func activate():
	"""Called when the lane key is pressed"""
	is_active = true
	flash_timer = flash_duration
	_update_material()

func _update_material():
	var material = get_surface_override_material(0)
	if not material:
		material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		set_surface_override_material(0, material)
	
	if material is StandardMaterial3D:
		material.albedo_color = active_color if is_active else inactive_color
