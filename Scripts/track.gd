@tool
extends Path3D

@export var lane_count: int = 4:
	set(value):
		lane_count = max(1, value)
		if Engine.is_editor_hint() and is_inside_tree():
			generate_lanes()

@export var total_width: float = 3.0:
	set(value):
		total_width = value
		if Engine.is_editor_hint() and is_inside_tree():
			generate_lanes()

@export var up_direction: Vector3 = Vector3.UP:
	set(value):
		up_direction = value.normalized()
		if Engine.is_editor_hint() and is_inside_tree():
			generate_lanes()

@export var auto_generate_on_ready: bool = true

@export_tool_button("Regenerate Lanes") var regenerate_lanes = generate_lanes

var lane_paths: Array[Path3D] = []

func _ready() -> void:
	if auto_generate_on_ready:
		generate_lanes()

func generate_lanes() -> void:
	clear_lanes()
	
	if not curve:
		push_error("Curve is not available")
		return
	
	if curve.point_count == 0:
		push_warning("Curve has no points")
		return
	
	# Calculate lane positions (centered around the parent path)
	var lane_offsets = _calculate_lane_offsets()
	
	# Create a Path3D for each lane
	for i in range(lane_count):
		var lane_path = Path3D.new()
		lane_path.name = "Lane%d" % i
		lane_path.curve = Curve3D.new()
		
		add_child(lane_path)
		lane_path.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner
		lane_paths.append(lane_path)
		
		_generate_lane_curve(lane_path.curve, curve, lane_offsets[i])

func _calculate_lane_offsets() -> Array[float]:
	var offsets: Array[float] = []
	
	# Calculate spacing to make lanes equidistant
	var half_width = total_width / 2.0
	var spacing = total_width / (lane_count - 1) if lane_count > 1 else 0.0
	
	for i in range(lane_count):
		var offset = -half_width + (i * spacing)
		offsets.append(offset)
	
	return offsets

func _generate_lane_curve(lane_curve: Curve3D, parent_curve: Curve3D, x_offset: float) -> void:
	# Copy each point from parent with offset applied
	for i in range(parent_curve.point_count):
		var point = parent_curve.get_point_position(i)
		var point_in = parent_curve.get_point_in(i)
		var point_out = parent_curve.get_point_out(i)
		var tilt = parent_curve.get_point_tilt(i)
		
		var offset_direction = _calculate_offset_direction(parent_curve, i, point, point_in, point_out)
		var offset_point = point + offset_direction * x_offset
		
		lane_curve.add_point(offset_point, point_in, point_out)
		lane_curve.set_point_tilt(i, tilt)

func _calculate_offset_direction(parent_curve: Curve3D, index: int, point: Vector3, point_in: Vector3, point_out: Vector3) -> Vector3:
	if parent_curve.point_count == 1:
		return Vector3.RIGHT
	
	var forward = _get_forward_direction(parent_curve, index, point, point_in, point_out)
	var offset_direction = forward.cross(up_direction).normalized()
	
	# If cross product failed (path parallel to up direction), use default
	if offset_direction.length_squared() < 0.01:
		return Vector3.RIGHT
	
	return offset_direction

func _get_forward_direction(parent_curve: Curve3D, index: int, point: Vector3, point_in: Vector3, point_out: Vector3) -> Vector3:
	# Priority: outgoing handle > incoming handle > next point > previous point
	if point_out.length_squared() > 0.01:
		return point_out.normalized()
	
	if index > 0 and point_in.length_squared() > 0.01:
		return -point_in.normalized()
	
	if index < parent_curve.point_count - 1:
		return (parent_curve.get_point_position(index + 1) - point).normalized()
	
	if index > 0:
		return (point - parent_curve.get_point_position(index - 1)).normalized()
	
	return Vector3.FORWARD

func update_lane_positions() -> void:
	if not curve or curve.point_count == 0:
		return
	
	var lane_offsets = _calculate_lane_offsets()
	
	for lane_index in range(lane_paths.size()):
		if lane_index >= lane_offsets.size():
			break
		
		var lane_path = lane_paths[lane_index]
		if not is_instance_valid(lane_path) or not lane_path.curve:
			continue
		
		var lane_curve = lane_path.curve
		var x_offset = lane_offsets[lane_index]
		
		# Only update if point counts match
		if lane_curve.point_count != curve.point_count:
			push_warning("Lane %d point count mismatch, regenerate lanes" % lane_index)
			continue
		
		# Update each point position
		for i in range(curve.point_count):
			var point = curve.get_point_position(i)
			var point_in = curve.get_point_in(i)
			var point_out = curve.get_point_out(i)
			
			var offset_direction = _calculate_offset_direction(curve, i, point, point_in, point_out)
			var offset_point = point + offset_direction * x_offset
			
			lane_curve.set_point_position(i, offset_point)

func clear_lanes() -> void:
	for lane_path in lane_paths:
		if is_instance_valid(lane_path):
			lane_path.queue_free()
	lane_paths.clear()
	
	# Also remove any existing lane children
	for child in get_children():
		if child.name.begins_with("Lane"):
			child.queue_free()
