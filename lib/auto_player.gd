class_name AutoPlayer extends "gerimon.gd"

var BallScene = preload("res://lib/head.tscn")

var hit_distance = 70
var width = 24

var players: Array = []
var balls: Array = []

func distance_to(other):
	return global_position.distance_to(other.global_position)

func move_closer(other):
	if distance_to(other) > hit_distance + width:
		senten()
	elif distance_to(other) > hit_distance + width / 2.0:
		tsuisoku()
	else:
		ninoashi()

func move_further():
	var actions = ["taisoku", "gensoku", "koten"]
	call(actions.pick_random())

func cancel_attack():
	if attacking && _frame < _4th:
		stand()

func cancel_unsoku():
	if walking:
		if _frame < _3rd or _frame > _6th:
			stand()

func attack_during_attack(other, attack):
	if action == "suiheigeri":
		if other._frame < 6:
			var actions = ["fujogeri", "manjigeri"]
			call(actions.pick_random())
	elif attack == "fujogeri":
		if other._frame < _10th:
			manjigeri()

func attack_after_action(other, other_action):
	if other_action == "suiheigeri":
		if other._frame > _6th:
			fujogeri()
	elif other_action == "fujogeri":
		if other._frame > _10th:
			manjigeri()
	elif other_action == "manjigeri":
		if other._frame > _7th:
			suiheigeri()

func dodge(other, other_action):
	if other_action:
		cancel_attack()
		if randf() > 0.6: call(["kosoku", "koten"].pick_random())
		elif randf() > 0.5 or distance_to(other) < hit_distance * 0.75: gensoku()
		else: taisoku()

func engage_player(other):
	if distance_to(other) < 30:
		var close_range_actions = ["hangetsuate", "tsuisoku"]
		call(close_range_actions.pick_random())
	elif distance_to(other) < 52:
		var mid_range_actions = ["fujogeri", "sensogeri", "manjigeri"]
		call(mid_range_actions.pick_random())
	else:
		var long_range_actions = ["fujogeri_forward", "suiheigeri", "sentainotsuki"]
		call(long_range_actions.pick_random())

func engage_ball(other):  # Renamed for inclusivity
	if distance_to(other) > hit_distance:
		call(["fujogeri", "sensogeri", "manjigeri"].pick_random())

func turn_towards(other):
	var at = -1 if other.position.x < position.x else 1
	if at != dir: ushiro()

func spot_attack(other):
	if other.attacking and other._frame > _4th:
		return other.action
	return null

func _process(_delta):
	super(_delta)
	if hit: return
	if paused: return
	if players.size() == 0 and balls.size() == 0: return

	var others = players.filter(func(o): return o != self).filter(func(o): return not o.hit)
	var other = others.pick_random() if others.size() > 0 else null

	#var balls_coming_towards = balls.filter(func(ball):
		#if ball.global_position.x < global_position.x and ball.velocity.x > 0: return true
		#elif ball.global_position.x > global_position.x and ball.velocity.x < 0: return true
		#return false)
	#var nearby_balls = balls_coming_towards.filter(func(ball): return distance_to(ball) < hit_distance * 4)
	#var _nearest_ball = nearby_balls.reduce(func(a, b): return a if distance_to(a) < distance_to(b) else b)
	
	if other:
		turn_towards(other)

		if other is Head:
			engage_ball(other)
		else:
			if distance_to(other) < hit_distance / 2.0:
				move_further()
			elif distance_to(other) > hit_distance:
				move_closer(other)

			var spot = spot_attack(other)
			if spot:
				dodge(other, spot)
			else:
				if distance_to(other) > 8 && distance_to(other) <= hit_distance:
					engage_player(other)
