extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Judge1.action == "stand":
		$Judge1.judge("fightround", 1, [1,2,3])
	if $Judge2.action == "stand":
		$Judge2.judge("fightround", 2, [3,2,1])
