extends Node

# Simple test to verify chord handling

func create_test_chart() -> ChartData:
	var chart = ChartData.new()
	chart.title = "Test Chart"
	chart.artist = "Test"
	chart.difficulty_name = "Test"
	chart.bpm = 120.0
	
	# Single note at 1 second
	var note1 = NoteData.new()
	note1.start_time = 1000.0
	note1.lane = 0
	note1.color = Note.NoteColor.RED
	chart.notes.append(note1)
	
	# Chord: 4 notes at the same time (2 seconds)
	for i in range(4):
		var note = NoteData.new()
		note.start_time = 2000.0
		note.lane = i
		note.color = [Note.NoteColor.RED, Note.NoteColor.BLUE, Note.NoteColor.GREEN, Note.NoteColor.YELLOW][i]
		chart.notes.append(note)
	
	# Another single note at 3 seconds
	var note2 = NoteData.new()
	note2.start_time = 3000.0
	note2.lane = 1
	note2.color = Note.NoteColor.BLUE
	chart.notes.append(note2)
	
	# Two-note chord at 4 seconds
	var note3 = NoteData.new()
	note3.start_time = 4000.0
	note3.lane = 0
	note3.color = Note.NoteColor.RED
	chart.notes.append(note3)
	
	var note4 = NoteData.new()
	note4.start_time = 4000.0
	note4.lane = 3
	note4.color = Note.NoteColor.YELLOW
	chart.notes.append(note4)
	
	return chart
