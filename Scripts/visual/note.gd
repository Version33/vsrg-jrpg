class_name Note
extends MeshInstance3D

signal despawned(note)

enum NoteColor {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE
}

const COLOR_MAP = {
	NoteColor.RED: Color(0.9, 0.2, 0.2),
	NoteColor.BLUE: Color(0.2, 0.5, 0.9),
	NoteColor.GREEN: Color(0.2, 0.9, 0.3),
	NoteColor.YELLOW: Color(0.95, 0.85, 0.2),
	NoteColor.PURPLE: Color(0.7, 0.2, 0.9)
}

const LOOKAHEAD_TIME = 2.0  # seconds

@export var note_color: NoteColor = NoteColor.RED:
	set(value):
		note_color = value
		_update_color()

var target_hit_time: float  # when note should be hit (ms)
var lane_index: int
var lane_path: Path3D
var lane_curve: Curve3D
var chart_manager: ChartManager

func setup(hit_time: float, lane: int, color: NoteColor, path: Path3D, manager: ChartManager):
	target_hit_time = hit_time
	lane_index = lane
	note_color = color
	lane_path = path
	lane_curve = path.curve
	chart_manager = manager

func _ready():
	_update_color()

func _process(_delta: float):
	if not chart_manager or not chart_manager.is_chart_playing():
		return
	
	var current_time = chart_manager.get_current_time()
	var time_until_hit = target_hit_time - current_time
	var progress = 1.0 - (time_until_hit / (LOOKAHEAD_TIME * 1000.0))
	
	# Clean up if note passed hit zone
	if progress > 1.2:
		despawned.emit(self)
		queue_free()
		return
	
	_update_position(clamp(progress, 0.0, 1.0))

func _update_position(progress: float):
	var distance = progress * lane_curve.get_baked_length()
	var pos = lane_curve.sample_baked(distance)
	global_position = lane_path.global_transform * pos

func _update_color():
	if not is_inside_tree():
		await ready
	
	var material = get_surface_override_material(0)
	if not material:
		material = StandardMaterial3D.new()
		set_surface_override_material(0, material)
	
	if material is StandardMaterial3D:
		material.albedo_color = COLOR_MAP.get(note_color, Color.WHITE)

func play_hit_effect():
	# TODO: Add particle effects, animations, etc.
	pass
