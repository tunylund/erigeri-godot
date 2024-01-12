extends Node2D

var current_scene = null

var _1on1scene = preload("res://game_scenes/1on1_scene.tscn")
var _1on2scene = preload("res://game_scenes/1on2_scene.tscn")
var _auto_playscene = preload("res://game_scenes/auto_play_scene.tscn")

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	goto_scene(_auto_playscene)

func goto_scene(next_scene):
	if current_scene != self: current_scene.free()
	current_scene = next_scene.instantiate()
	current_scene.game_over.connect(_on_game_over)
	get_tree().root.add_child.call_deferred(current_scene)

func _on_game_over():
	call_deferred("goto_scene", _auto_playscene)

func _process(_delta):
	if Input.is_action_just_pressed("1on1game"):
		call_deferred("goto_scene", _1on1scene)
	if Input.is_action_just_pressed("1on2game"):
		call_deferred("goto_scene", _1on2scene)
	if Input.is_action_just_pressed("Mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
