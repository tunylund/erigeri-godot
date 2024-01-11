extends CharacterBody2D

signal judgement_finished

var initial_position: Vector2
var judgement: Dictionary
var speed = 100

var dir: int:
	get: return -1 if $AnimatedSprite2D.flip_h else 1

var action: String:
	get: return $AnimatedSprite2D.animation

func _physics_process(_delta):
	move_and_slide()

func _ready():
	initial_position = position
	_reset()
	
func stand():
	velocity = Vector2.ZERO
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.play("stand")

func judge(round_type: String, player_count: int, scores: Array):
	scores.sort_custom(func(a, b): return true if a.score > b.score else false)
	judgement = {
		"round_type": round_type,
		"player_count": player_count,
		"scores": scores,
	}
	_enter()

func _enter():
	velocity = Vector2(speed, 0)
	$AnimatedSprite2D.play("walk")

func _exit():
	velocity = Vector2(-speed, 0)
	$AnimatedSprite2D.flip_h = true
	$AnimatedSprite2D.play("walk")

func _talk():
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("talk")
	_say_next(judgement.round_type, judgement.player_count, judgement.scores, 0)

func _say_next(round_type: String, player_count: int, scores: Array, how_many_have_been_judged: int):
	var choices = [""]
	var texts = {
		"ball": [["Oh dear...", "...are you ok?", "Gosh! That probably hurt.", "Maybe we should reconsider this..."]],
		"winner": [["The winner is {color}.", "{color} wins the round."]],
		"second": [["{color} is second.", "{color} comes in second."]],
		"loser": [
			["{color} you r-rated-word-i-should\'t say.", "{color}... really?", "just... just don\'t, {color}."],
			["{color} you can stop now.", "{color} you can do better.", "C\'mon {color}"],
			["{color} almost there.", "maybe next time try to do better {color}."],
			["Tough luck {color}."]
		]
	}

	if how_many_have_been_judged == 0: choices = texts["ball"] if round_type == "ballround" else texts["winner"]
	elif how_many_have_been_judged == player_count - 1: choices = texts["loser"]
	else: choices = texts["second"]

	var score = scores[how_many_have_been_judged]
	var score_texts = choices[score.score % choices.size()]
	var text = score_texts.pick_random()

	$Label.text = text.replace("{color}", score.color.capitalize())

	if round_type == "ballround" or how_many_have_been_judged >= player_count - 1:
		await get_tree().create_timer(2.0).timeout
		if (action == "talk"): 
			$Label.text = ""
			_exit()
	else:
		await get_tree().create_timer(2.0).timeout
		if (action == "talk"): _say_next(round_type, player_count, scores, how_many_have_been_judged + 1)

func _reset():
	stand()
	$Label.text = ""
	position = initial_position

func _process(_delta):
	if action == "walk" && dir == 1:
		if position.x >= initial_position.x + 100:
			_talk()

	elif action == "walk" && dir == -1:
		if position.x <= initial_position.x:
			stand()
			emit_signal("judgement_finished")

	if action != "stand" && Input.is_action_just_pressed("attack"):
		_reset()
		emit_signal("judgement_finished")
