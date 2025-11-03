extends MeshInstance3D

enum NoteColor {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE
}

@export var note_color: NoteColor = NoteColor.RED:
	set(value):
		note_color = value
		_update_color()

# Color definitions - easily customizable
const COLOR_MAP = {
	NoteColor.RED: Color(0.9, 0.2, 0.2),
	NoteColor.BLUE: Color(0.2, 0.5, 0.9),
	NoteColor.GREEN: Color(0.2, 0.9, 0.3),
	NoteColor.YELLOW: Color(0.95, 0.85, 0.2),
	NoteColor.PURPLE: Color(0.7, 0.2, 0.9)
}

func _ready():
	_update_color()

func _update_color():
	if not is_inside_tree():
		await ready
	
	var material = get_surface_override_material(0)
	if not material:
		material = StandardMaterial3D.new()
		set_surface_override_material(0, material)
	
	if material is StandardMaterial3D:
		material.albedo_color = COLOR_MAP.get(note_color, Color.WHITE)
