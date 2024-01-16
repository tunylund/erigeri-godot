extends Node2D

func _ready():
	AudioServer.set_bus_mute(0, true)

	var players = [$Blue, $Green]
	$Blue.players = players
	$Green.players = players
