extends Node2D

var Player = preload("res://player.tscn")
var Gerimon = preload("res://gerimon.tscn")

var gravity = 980
var player
var gerimon
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	player = Player.instantiate()
	gerimon = Gerimon.instantiate()
	player.position = Vector2(164, 350)
	gerimon.position = Vector2(364, 350)
	add_child(player)
	add_child(gerimon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player.position = player.position.clamp(Vector2.ZERO, screen_size)
	gerimon.position = gerimon.position.clamp(Vector2.ZERO, screen_size)
	#player.velocity.y += gravity * delta
	#if player.is_on_floor(): player.velocity.y = 0
