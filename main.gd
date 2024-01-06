extends Node2D

var PlayerScene = preload("res://player.tscn")
var GerimonScene = preload("res://gerimon.tscn")

var gravity = 980
var player
var gerimon
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	player = PlayerScene.instantiate()
	player.color = "orange"
	gerimon = GerimonScene.instantiate()
	gerimon.color = "blue"
	player.position = Vector2(164, 350)
	gerimon.position = Vector2(264, 350)
	add_child(player)
	add_child(gerimon)
	gerimon.hit_success.connect(_on_hit)
	player.hit_success.connect(_on_hit)

func _process(_delta):
	player.position = player.position.clamp(Vector2.ZERO, screen_size)
	gerimon.position = gerimon.position.clamp(Vector2.ZERO, screen_size)

func _on_hit(attacker, _victim, is_head_shot):
	var score = 4 if is_head_shot else 1
	$Scores.add_points(attacker.color, score)
