extends Node

var viewport
var activeButton : Node3D = null
@export var lockedY : float = 2.8
@export var buttons : Array[Node3D] = []  # Assign buttons in inspector in order: left, center-left, center-right, right

# Track which lanes are currently pressed via keyboard
var pressed_lanes : Array[bool] = [false, false, false, false]

func _ready() -> void:
	viewport = get_viewport()

func _process(delta: float) -> void:
	var new_button = get_button_from_screen_section()
	
	if new_button != activeButton:
		if activeButton:
			activeButton.set_active(false)
		if new_button:
			new_button.set_active(true)
		activeButton = new_button
	
	# Update button visuals based on keyboard presses
	_update_button_presses()

func _update_button_presses() -> void:
	for i in range(min(buttons.size(), pressed_lanes.size())):
		if pressed_lanes[i]:
			buttons[i].set_active(true)

func get_button_from_screen_section() -> Node3D:
	var mouse_pos = viewport.get_mouse_position()
	var viewport_width = viewport.get_visible_rect().size.x
	var section_width = viewport_width / 4.0
	
	var index = int(mouse_pos.x / section_width)
	index = clampi(index, 0, 3)
	
	return buttons[index] if index < buttons.size() else null

func get_mouse_position_on_plane(plane_position: Vector3, plane_normal: Vector3) -> Vector3:
	var camera = viewport.get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(plane_normal, plane_position)
	var intersection = plane.intersects_ray(from, normal)
	
	return intersection if intersection else Vector3.ZERO
