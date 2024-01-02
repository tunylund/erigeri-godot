extends Node2D

var Player = preload("res://player.tscn")

var gravity = 980
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.instantiate()
	player.position = Vector2(164, 350)
	add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player.velocity.y += gravity * delta
	if (player.is_on_floor()):
		player.velocity.y = 0
