extends Node2D

func _ready():
	var players = [$Blue, $Green]
	$Blue.players = players
	$Green.players = players
