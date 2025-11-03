class_name NoteData
extends Resource

@export var start_time: float = 0.0  # milliseconds
@export_range(0, 3, 1) var lane: int = 0  # 0-3 for 4-key
@export var end_time: float = 0.0  # 0 for tap note, >0 for hold note
@export var color: Note.NoteColor = Note.NoteColor.RED

func is_hold_note() -> bool:
	return end_time > 0
