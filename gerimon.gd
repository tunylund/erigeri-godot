class_name Gerimon extends CharacterBody2D

signal hit

var speed = 100
var screen_size # Size of the game window.
var offset = 24
var dir = 1
var directions = { "right": 1, "left": -1 }
var paused = false

func _ready():
	stand()
	screen_size = get_viewport_rect().size
	if position == Vector2.ZERO:
		position = screen_size / Vector2(2, 2)
	
func _process(delta):
	dir = -1 if velocity.x < 0 else 1
	$AnimatedSprite2D.flip_v = false
	$AnimatedSprite2D.flip_h = dir < 0
	$AnimatedSprite2D.offset.x = -24 if dir > 0 else -72
	$AnimatedSprite2D.play()
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

func stand():
	$AnimatedSprite2D.animation = "stand"

func ushiro():
	pass
	
func kosoku():
	pass
	
func senten():
	pass

func koten():
	pass
	
func gensoku():
	pass
	
func ninoashi():
	pass

func tsuisoku():
	$AnimatedSprite2D.animation = "tsuisoku"

func taisoku():
	pass
