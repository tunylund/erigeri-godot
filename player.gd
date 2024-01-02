class_name Player extends "gerimon.gd"

func _process(delta):
	super(delta)
	attack()
	unsoku()
	
func attack():
	pass

func unsoku():
	if paused: return
	
	if Input.is_action_pressed("attack"): return

	if Input.is_action_pressed("turn"):
		ushiro()
	else:
		if Input.is_action_pressed("up"):
			kosoku()
		if Input.is_action_pressed("down"):
			if Input.is_action_pressed(directions.find_key(dir)):
				senten()
			elif Input.is_action_pressed(directions.find_key(-dir)):
				koten()
			else:
				gensoku()
	
	if Input.is_action_pressed(directions.find_key(dir)):
		ninoashi()
		if $AnimatedSprite2D.animation == "ninoashi" && $AnimatedSprite2D.frame > 1:
			tsuisoku()

	if Input.is_action_pressed(directions.find_key(-dir)):
		taisoku()
