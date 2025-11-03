# Chart Creation Guide

## Using Godot Resources for Charts

Charts are now stored as Godot Resources (`.tres` files), making them easy to create and edit in the inspector.

### Creating a New Chart

1. **In Godot Editor:**
   - Right-click in FileSystem → New Resource
   - Select `ChartData`
   - Save as `Charts/my_song.tres`

2. **Edit Chart Properties:**
   - Click the `.tres` file
   - In Inspector, set:
     - Audio File: `"song.mp3"` (place in `Music/` folder)
     - Title: Song name
     - Artist: Artist name
     - Difficulty Name: "Easy", "Hard", etc.
     - BPM: Beats per minute

3. **Add Notes:**
   - Expand `Notes` array
   - Click `+` to add new note
   - For each note, set:
     - **Start Time**: When to hit (milliseconds, e.g., `1000` = 1 second)
     - **Lane**: 0-3 (left to right)
     - **End Time**: 0 for tap note, >0 for hold note
     - **Color**: RED, BLUE, GREEN, YELLOW, or PURPLE

### Creating Charts Programmatically

```gdscript
var chart = ChartData.new()
chart.title = "My Song"
chart.artist = "Artist Name"
chart.bpm = 120.0

var note = NoteData.new()
note.start_time = 1000.0  # 1 second
note.lane = 0
note.color = Note.NoteColor.RED
chart.notes.append(note)

# Save as resource
ResourceSaver.save(chart, "res://Charts/my_song.tres")
```

### Loading Charts

```gdscript
# Method 1: Preload (compile-time)
@export var chart: ChartData = preload("res://Charts/my_song.tres")

# Method 2: Load (runtime)
var chart = load("res://Charts/my_song.tres") as ChartData

# Method 3: In ChartManager
chart_manager.load_chart(chart)
```

### Tips

- **Timing**: Start times are in milliseconds (1000ms = 1 second)
- **Chords**: Multiple notes with same `start_time` create chords
- **Colors**: Can be different from lane (for visual variety or patterns)
- **BPM**: Used for reference, doesn't affect timing (timing is absolute)
