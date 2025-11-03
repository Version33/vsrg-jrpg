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
@export var generate_indicators: bool = true

@export_tool_button("Regenerate Lanes") var regenerate_lanes = generate_lanes

var lane_paths: Array[Path3D] = []

# Preload the indicator scene
const LaneIndicatorScene = preload("res://Scenes/LaneIndicator.tscn")

func _ready() -> void:
	# Only auto-generate in editor, or at runtime if no lanes exist
	if Engine.is_editor_hint():
		if auto_generate_on_ready:
			generate_lanes()
	else:
		# At runtime, collect existing lanes from the scene
		_collect_existing_lanes()

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
	
	# Create a Path3D for each lane - much simpler!
	# Just reuse the parent curve and translate the Path3D node
	for i in range(lane_count):
		var lane_path = Path3D.new()
		lane_path.name = "Lane%d" % i
		lane_path.curve = curve  # Reuse the same curve!
		
		# Calculate offset direction perpendicular to the path
		var offset_direction = _get_offset_direction()
		var offset = lane_offsets[i]
		lane_path.position = offset_direction * offset
		
		add_child(lane_path)
		lane_path.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner
		lane_paths.append(lane_path)
		
		# Create lane indicator as child of the lane
		if generate_indicators:
			_create_lane_indicator(lane_path, i)

func _calculate_lane_offsets() -> Array[float]:
	var offsets: Array[float] = []
	
	# Calculate spacing to make lanes equidistant
	var half_width = total_width / 2.0
	var spacing = total_width / (lane_count - 1) if lane_count > 1 else 0.0
	
	# Generate offsets from right to left (Lane 0 on right, Lane 3 on left)
	# This gives proper 0123 ordering from player's perspective
	for i in range(lane_count):
		var offset = half_width - (i * spacing)
		offsets.append(offset)
	
	return offsets

func _get_offset_direction() -> Vector3:
	"""Calculate the perpendicular direction for lane offsets"""
	if not curve or curve.point_count < 2:
		return Vector3.RIGHT
	
	# Get the forward direction of the path
	var start_point = curve.get_point_position(0)
	var end_point = curve.get_point_position(curve.point_count - 1)
	var forward = (end_point - start_point).normalized()
	
	# Cross with up direction to get perpendicular offset
	var offset_direction = forward.cross(up_direction).normalized()
	
	# If cross product failed (path parallel to up direction), use default
	if offset_direction.length_squared() < 0.01:
		return Vector3.RIGHT
	
	return offset_direction

func update_lane_positions() -> void:
	"""Update lane positions based on current total_width setting"""
	if not curve or curve.point_count == 0:
		return
	
	var lane_offsets = _calculate_lane_offsets()
	var offset_direction = _get_offset_direction()
	
	for lane_index in range(lane_paths.size()):
		if lane_index >= lane_offsets.size():
			break
		
		var lane_path = lane_paths[lane_index]
		if not is_instance_valid(lane_path):
			continue
		
		# Simply update the position - no curve manipulation needed!
		lane_path.position = offset_direction * lane_offsets[lane_index]

func _create_lane_indicator(lane_path: Path3D, lane_index: int) -> void:
	"""Create a lane indicator at the judgement zone (Z=0) for this lane"""
	var indicator = LaneIndicatorScene.instantiate()
	indicator.name = "Indicator"
	indicator.lane_index = lane_index
	
	# Position at judgement zone (Z=0, Y=0, X=0 relative to lane)
	indicator.position = Vector3.ZERO
	
	lane_path.add_child(indicator)
	indicator.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner

func _collect_existing_lanes() -> void:
	"""Collect references to lanes that already exist in the scene (at runtime)"""
	lane_paths.clear()
	for child in get_children():
		if child is Path3D and child.name.begins_with("Lane"):
			lane_paths.append(child)
	
	# Sort by extracting the number from "LaneN" and comparing numerically
	lane_paths.sort_custom(func(a, b): 
		var a_num = int(a.name.substr(4))  # Extract number from "Lane0", "Lane1", etc.
		var b_num = int(b.name.substr(4))
		return a_num < b_num
	)

func clear_lanes() -> void:
	for lane_path in lane_paths:
		if is_instance_valid(lane_path):
			lane_path.queue_free()
	lane_paths.clear()
	
	# Also remove any existing lane children
	for child in get_children():
		if child.name.begins_with("Lane"):
			child.queue_free()
