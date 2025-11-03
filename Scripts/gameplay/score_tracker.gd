class_name ScoreTracker
extends Node

signal judgement_recorded(judgement: String, combo: int, score: int)
signal combo_broken()

const SCORE_VALUES = {
	"perfect": 300,
	"great": 200,
	"good": 100,
	"miss": 0
}

var score: int = 0
var combo: int = 0
var max_combo: int = 0
var judgements = {
	"perfect": 0,
	"great": 0,
	"good": 0,
	"miss": 0
}

func record_hit(judgement: String):
	judgements[judgement] += 1
	
	if judgement != "miss":
		combo += 1
		max_combo = max(combo, max_combo)
		score += SCORE_VALUES[judgement] * _get_combo_multiplier()
	else:
		if combo > 0:
			combo_broken.emit()
		combo = 0
	
	judgement_recorded.emit(judgement, combo, score)

func record_miss():
	record_hit("miss")

func get_accuracy() -> float:
	var total = judgements["perfect"] + judgements["great"] + judgements["good"] + judgements["miss"]
	if total == 0:
		return 100.0
	
	var weighted = judgements["perfect"] * 1.0 + judgements["great"] * 0.8 + judgements["good"] * 0.5
	return (weighted / total) * 100.0

func reset():
	score = 0
	combo = 0
	max_combo = 0
	judgements = {"perfect": 0, "great": 0, "good": 0, "miss": 0}

func _get_combo_multiplier() -> float:
	return 1.0 + (combo / 50.0)
