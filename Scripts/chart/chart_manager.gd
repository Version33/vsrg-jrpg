class_name ChartManager
extends Node

const LOOKAHEAD_TIME = 2.0  # seconds
const TIMING_WINDOWS = {
	"perfect": 25.0,   # ±25ms
	"great": 50.0,     # ±50ms
	"good": 100.0,     # ±100ms
	"miss": 150.0      # ±150ms
}

@export var track: Path3D
@export var audio_player: AudioStreamPlayer
@export var test_mode: bool = false  # If true, uses internal timer instead of audio

var note_scene = preload("res://Scenes/Note.tscn")
var chart_data: ChartData
var active_notes: Array[Note] = []
var next_note_index: int = 0
var test_time: float = 0.0  # Internal timer for test mode
var is_playing: bool = false

func load_chart(data: ChartData):
	chart_data = data
	next_note_index = 0
	clear_notes()
	print("Loaded: %s - %s [%s]" % [data.artist, data.title, data.difficulty_name])

func start_chart():
	if not chart_data:
		push_error("No chart loaded")
		return
	
	if test_mode:
		# Test mode: use internal timer
		test_time = 0.0
		is_playing = true
		print("Starting chart in TEST MODE (no audio)")
	else:
		# Normal mode: use audio
		if not audio_player.stream:
			push_error("No audio loaded")
			return
		audio_player.play()
		is_playing = true

func _process(delta: float):
	if not chart_data or not is_playing:
		return
	
	# Update test mode timer
	if test_mode:
		test_time += delta
	
	_spawn_notes()

func _spawn_notes():
	var current_time = get_current_time()
	var spawn_window = current_time + (LOOKAHEAD_TIME * 1000.0)
	
	while next_note_index < chart_data.notes.size():
		var note_data = chart_data.notes[next_note_index]
		
		if note_data.start_time <= spawn_window:
			_spawn_note(note_data)
			next_note_index += 1
		else:
			break

func _spawn_note(note_data: NoteData):
	var note = note_scene.instantiate()
	var lane = track.lane_paths[note_data.lane]
	
	lane.add_child(note)
	note.setup(note_data.start_time, note_data.lane, note_data.color, lane, self)
	note.despawned.connect(_on_note_despawned)
	
	active_notes.append(note)

func check_hit_in_lane(lane_index: int):
	var current_time = get_current_time()
	var closest_note: Note = null
	var best_diff = INF
	
	for note in active_notes:
		if note.lane_index != lane_index:
			continue
		
		var diff = abs(note.target_hit_time - current_time)
		
		if diff > TIMING_WINDOWS["miss"]:
			continue
		
		if diff < best_diff:
			best_diff = diff
			closest_note = note
	
	if closest_note:
		var judgement = _calculate_judgement(best_diff)
		_register_hit(closest_note, judgement)

func _calculate_judgement(time_diff: float) -> String:
	if time_diff <= TIMING_WINDOWS["perfect"]:
		return "perfect"
	elif time_diff <= TIMING_WINDOWS["great"]:
		return "great"
	elif time_diff <= TIMING_WINDOWS["good"]:
		return "good"
	else:
		return "miss"

func _register_hit(note: Note, judgement: String):
	print("Hit! Lane %d - %s (%.1fms)" % [note.lane_index, judgement, abs(note.target_hit_time - get_current_time())])
	
	note.play_hit_effect()
	active_notes.erase(note)
	note.queue_free()
	
	# TODO: Send to ScoreTracker

func _on_note_despawned(note: Note):
	active_notes.erase(note)
	print("Miss! Lane %d" % note.lane_index)
	# TODO: Send miss to ScoreTracker

func clear_notes():
	for note in active_notes:
		if is_instance_valid(note):
			note.queue_free()
	active_notes.clear()

func get_current_time() -> float:
	"""Returns current playback time in milliseconds"""
	if test_mode:
		return test_time * 1000.0
	else:
		return audio_player.get_playback_position() * 1000.0

func is_chart_playing() -> bool:
	"""Returns true if chart is currently playing"""
	if test_mode:
		return is_playing
	else:
		return audio_player.playing
