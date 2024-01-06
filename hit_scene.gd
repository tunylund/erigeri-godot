extends Node2D

@export var gerimon_scene: PackedScene

func _ready():
	$UHeadVictim.ushiro()
	$UHeadAttacker.ushiro()

func _process(_delta):
	$BodyAttacker.manjigeri()
	$HeadAttacker.hangetsuate()
	$UHeadAttacker.fujogeri()

func _on_hit(attacker, victim, is_head_shot):
	print("hit success", is_head_shot, attacker, victim)
