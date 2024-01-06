extends Node2D

var scores = {
	"orange": { "current": 0, "total": 0 },
	"blue": { "current": 0, "total": 0 },
	"green": { "current": 0, "total": 0 },
}
func add_points(color, value):
	scores[color].current = clamp(scores[color].current + value, 0, 4)
	scores[color].total = scores[color].total + value
	_update_scores()

func _update_scores():
	$FlowContainer/Orange/ScoreCircle.value = scores.orange.current
	$FlowContainer/Orange/Label.text = str(scores.orange.total)
	$FlowContainer/Blue/ScoreCircle.value = scores.blue.current
	$FlowContainer/Blue/Label.text = str(scores.blue.total)
	$FlowContainer/Green/ScoreCircle.value = scores.green.current
	$FlowContainer/Green/Label.text = str(scores.green.total)
