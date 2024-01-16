class_name AnimPlayer extends Node2D

var GerimonScene = preload("res://lib/Gerimon.tscn")

var unsokus = [
	"stand",
	"ushiro",
	"tsuisoku",
	"taisoku",
	"kosoku",
	"gensoku",
]
var actions = [
	"fujogeri",
	"fujogeri_forward",
	"hangetsuate",
	"sentainotsuki",
	"manjigeri",
	"suiheigeri",
	"sensogeri"
]
var combos = [
	["sentainotsuki", "fujogeri"],
	["sentainotsuki", "fujogeri_forward"],
	["senten", "fujogeri"],
	["senten", "fujogeri_forward"],
	["manjigeri", "hangetsuate"],
	["koten", "hangetsuate"],
	["senten", "hangetsuate"],
	["sensogeri", "sentainotsuki"],
	["manjigeri", "sentainotsuki"],
	["fujogeri", "manjigeri"],
	["koten", "manjigeri"],
	["senten", "manjigeri"],
	["sensogeri", "suiheigeri"],
	["senten", "sensogeri"],
	["manjigeri", "sensogeri"],
	["koten", "sensogeri"],
]
var unsoku_animations = []
var action_animations = []
var combo_animations = []

func _ready():
	AudioServer.set_bus_mute(0, true)
	
	var window = get_tree().root
	window.size = Vector2i(1800, 1200)
	var screen_positions = split_viewport_into_squares()
	for action in unsokus:
		var mon = GerimonScene.instantiate()
		#mon.ushiro()
		unsoku_animations.append({
			"mon": mon,
			"position": screen_positions.pop_front(),
			"action": action
		})
		add_child(mon)
		
	for action in actions:
		var mon = GerimonScene.instantiate()
		#mon.ushiro()
		action_animations.append({
			"mon": mon,
			"position": screen_positions.pop_front(),
			"action": action
		})
		add_child(mon)
	
	for combo in combos:
		var mon = GerimonScene.instantiate()
		#mon.ushiro()
		combo_animations.append({
			"mon": mon,
			"position": screen_positions.pop_front(),
			"combo": combo
		})
		add_child(mon)
	
func _process(_delta):
	for animation in unsoku_animations:
		if animation.mon.action == "stand": animation.mon.position = animation.position
		animation.mon[animation.action].call()
		animation.mon.position = animation.mon.position.clamp(Vector2.ZERO, get_viewport_rect().size)
		
	for animation in action_animations:
		if animation.mon.action == "stand": animation.mon.position = animation.position
		animation.mon[animation.action].call()
		animation.mon.position = animation.mon.position.clamp(Vector2.ZERO, get_viewport_rect().size)
	
	for animation in combo_animations:
		animation.mon.position = animation.mon.position.clamp(Vector2.ZERO, get_viewport_rect().size)
		var mon = animation.mon
		var combo = animation.combo
		if mon.action == "stand":
			mon.position = animation.position
			mon[combo[0]].call()
		elif mon.action == combo[0]:
			mon[combo[1]].call()
		elif mon.action == combo[1]:
			mon[combo[0]].call()

func split_viewport_into_squares():
	var viewport_size = Vector2i(get_viewport_rect().size)
	var margin = Vector2i(20, 10)
	var space_per_anim = Vector2i(96, 64) + margin * 2
	var square_count = viewport_size / space_per_anim
	var square_size = Vector2i(viewport_size / square_count)

	var positions = []
	for y in range(square_count.y):
		for x in range(square_count.x):
			positions.append(Vector2i(x, y) * square_size + margin)

	for y in range(square_count.y):
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size = Vector2(viewport_size.x*2, 10)
		collision_shape.position = Vector2(0, y * square_size.y + square_size.y/2 + 32)
		$StaticBody2D.add_child(collision_shape)
		
	return positions
