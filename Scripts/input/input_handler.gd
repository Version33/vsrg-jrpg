class_name InputHandler
extends Node

signal lane_pressed(lane_index: int)

@export var chart_manager: ChartManager

func _input(event: InputEvent):
	if not event.is_pressed() or event.is_echo():
		return
	
	var lane = _get_lane_from_action(event)
	
	if lane >= 0:
		lane_pressed.emit(lane)
		if chart_manager:
			chart_manager.check_hit_in_lane(lane)

func _get_lane_from_action(event: InputEvent) -> int:
	if event.is_action_pressed("Lane0"):
		return 0
	elif event.is_action_pressed("Lane1"):
		return 1
	elif event.is_action_pressed("Lane2"):
		return 2
	elif event.is_action_pressed("Lane3"):
		return 3
	else:
		return -1
