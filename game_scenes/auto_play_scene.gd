extends Node2D

signal game_over

var gravity = 980
var screen_size
var players = []

func _ready():
	screen_size = get_viewport_rect().size
	players = [$AutoPlayer1, $AutoPlayer2, $AutoPlayer3]
	$AutoPlayer1.hit_success.connect(_on_hit)
	$AutoPlayer2.hit_success.connect(_on_hit)
	$AutoPlayer3.hit_success.connect(_on_hit)
	$AutoPlayer1.players = players
	$AutoPlayer2.players = players
	$AutoPlayer3.players = players
	$Judge.judgement_finished.connect(_on_judgement_finished)
	$Scores.reached_round_max.connect(_on_reached_round_max)

func _process(_delta):
	for player in players:
		player.position = player.position.clamp(Vector2.ZERO, screen_size)

func _on_judgement_finished():
	for player in players:
		player.position = player.initial_position
		player.direction = player.initial_direction
		player.paused = false
	$Scores.reset_current_scores()
	
func _on_hit(attacker, _victim, is_head_shot):
	var score = 4 if is_head_shot else 1
	$Scores.add_points(attacker.color, score)

func _on_reached_round_max():
	for player in players: player.paused = true
	$Judge.judge("fightround", players.size(), $Scores.current_scores)

