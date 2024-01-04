extends Node2D

@export var gerimon_scene: PackedScene

func _ready():
	pass

func _process(_delta):
	$BodyAttacker.manjigeri()
	$HeadAttacker.hangetsuate()

func _on_hit(is_head_shot):
	print("hit success", is_head_shot)
