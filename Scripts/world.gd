extends Node3D

@onready var chart_manager = $VSRG/ChartManager
@onready var input_handler = $VSRG/InputHandler
@onready var track = $VSRG/Track

func _ready() -> void:
	# Connect input handler to lane indicators
	input_handler.lane_pressed.connect(_on_lane_pressed)
	
	# Enable test mode (no audio required)
	chart_manager.test_mode = true
	
	# Create and load test chart
	var test_chart_creator = load("res://Scripts/chart/test_chart.gd").new()
	var test_chart = test_chart_creator.create_test_chart()
	chart_manager.load_chart(test_chart)
	
	# Start playback after a short delay
	await get_tree().create_timer(1.0).timeout
	chart_manager.start_chart()
	print("Test chart started! Press A/S/D/F keys to hit notes")

func _on_lane_pressed(lane_index: int):
	"""Called when a lane key is pressed"""
	# Indicators are now children of their respective lanes
	var lane = track.get_node_or_null("Lane%d" % lane_index)
	if lane:
		var indicator = lane.get_node_or_null("Indicator")
		if indicator and indicator.has_method("activate"):
			indicator.activate()
