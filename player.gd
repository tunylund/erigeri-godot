class_name Player extends "gerimon.gd"

var directions = { "left": -1, "right": 1 }

func _process(delta):
	super(delta)
	attackControls()
	unsokuControls()
	
func attackControls():
	if paused:
		return
	
	if !Input.is_action_pressed("attack"):
		return

	#var tDist = Infinity
	#var dist = 0
	#for(let player of this.stage.lists.players) {
	  #if(player != this) {
		#dist = Math.abs(this.p.x - player.p.x)
		#if(dist < tDist) {
		  #target = player
		  #tDist = dist
		#}
	  #}
	#}
#is_action_just_pressed
	if Input.is_action_pressed("up") && Input.is_action_pressed(directions.find_key(dir)):
		fujogeri_forward()

	if Input.is_action_pressed("up"):
		fujogeri()

	if Input.is_action_pressed("down") && Input.is_action_pressed(directions.find_key(-dir)):
		hangetsuate()

	if Input.is_action_pressed("down") && Input.is_action_pressed(directions.find_key(dir)):
		sentainotsuki()

	if Input.is_action_pressed("down"):
		manjigeri()

	if Input.is_action_pressed(directions.find_key(dir)):
		suiheigeri()

	if Input.is_action_pressed(directions.find_key(-dir)):
		sensogeri()

func unsokuControls():
	if paused:
		return
	
	if Input.is_action_pressed("attack"):
		return

	if Input.is_action_pressed("turn"):
		ushiro()

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
		if $AnimatedSprite2D.animation == "ninoashi" && _frame > _1st:
			stand()
			tsuisoku()

	if Input.is_action_pressed(directions.find_key(-dir)):
		taisoku()
	
	
