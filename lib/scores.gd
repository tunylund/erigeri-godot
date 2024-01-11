extends Node2D

signal reached_round_max

var scores = {
	"orange": { "current": 0, "total": 0 },
	"blue": { "current": 0, "total": 0 },
	"green": { "current": 0, "total": 0 },
}

var current_scores: Array:
	get: return [
		{ "color": "orange", "score": scores.orange.current },
		{ "color": "blue", "score": scores.blue.current },
		{ "color": "green", "score": scores.green.current },
	]

func did_orange_win():
	return scores.orange.current > scores.blue.current && scores.orange.current > scores.green.current

func reset_current_scores():
	scores.orange.current = 0
	scores.blue.current = 0
	scores.green.current = 0
	_update_scores()

func add_points(color, value):
	scores[color].current = clamp(scores[color].current + value, 0, 4)
	scores[color].total = scores[color].total + value
	if scores[color].current >= 4: emit_signal("reached_round_max")
	_update_scores()

func _update_scores():
	$FlowContainer/Orange/ScoreCircle.value = scores.orange.current
	$FlowContainer/Orange/Label.text = str(scores.orange.total)
	$FlowContainer/Blue/ScoreCircle.value = scores.blue.current
	$FlowContainer/Blue/Label.text = str(scores.blue.total)
	$FlowContainer/Green/ScoreCircle.value = scores.green.current
	$FlowContainer/Green/Label.text = str(scores.green.total)
