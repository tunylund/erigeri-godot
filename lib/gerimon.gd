class_name Gerimon extends CharacterBody2D

signal hit_success(attacker, victim, is_head_shot)

var HeadScene = preload("res://lib/head.tscn")
var hit_box_detection = preload("res://lib/hit_box_detection.gd")
var collisions = hit_box_detection.read_from_file()

@export var color: String = "green"
@export var direction: int:
	get: return dir
	set (new_dir):
		if new_dir != dir:
			_turn()

var initial_position
var initial_direction
var speed = 50
var jump_speed = 200
var dir = 1
var paused = false
var hit = false
var landed = true
var attacking = false
var walking = false
var jumping = false
var target = null
var sounded = false

const gravity = 980
const interpolation_multiplier = 4
const _1st = 1 * interpolation_multiplier
const _2nd = 2 * interpolation_multiplier
const _3rd = 3 * interpolation_multiplier
const _4th = 4 * interpolation_multiplier
const _5th = 5 * interpolation_multiplier
const _6th = 6 * interpolation_multiplier
const _7th = 7 * interpolation_multiplier
const _8th = 8 * interpolation_multiplier
const _10th = 10 * interpolation_multiplier
const _11th = 11 * interpolation_multiplier
const _12th = 12 * interpolation_multiplier
const _13th = 13 * interpolation_multiplier
const _16th = 16 * interpolation_multiplier
	
var _frame: int:
	get: return $AnimatedSprite2D.frame

var action: String:
	get: return $AnimatedSprite2D.animation.replace("_i", "")

func _play_animation(animation_name):
	$AnimatedSprite2D.play(animation_name + "_i")

func _ready():
	initial_position = position
	initial_direction = dir
	$BodyArea.area_entered.connect(_on_body_hit)
	$HeadArea.area_entered.connect(_on_head_hit)
	$AnimatedSprite2D.animation_finished.connect(_stand_at_end_of_action)
	$AnimatedSprite2D.animation_changed.connect(_clear_frame_step_listeners)
	$AnimatedSprite2D.frame_changed.connect(_sound_missed_hit)
	var edge_color = Color({
		"orange": "#f07900",
		"blue": "#69f",
		"green": "#4d5",
	}[color])
	$AnimatedSprite2D.material.set_shader_parameter("edge_color", edge_color)
	stand()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y > 0 and is_on_floor():
		velocity.y = 0

func _process(_delta):
	$AnimatedSprite2D.flip_v = false
	move_and_slide()
	_update_collisions()
	if is_on_floor():
		landed = true
		jumping = false

func _update_collisions():
	var empty = Rect2i()
	var collision = collisions.get(action, {})
	_update_collision($HeadArea/HeadShape, collision.get("head", {}).get(_frame, empty))
	_update_collision($BodyArea/BodyShape, collision.get("torso", {}).get(_frame, empty))
	_update_collision($HitArea/HitShape, collision.get("hit", {}).get(_frame, empty))
	
	var collision_rect = collision.get("body", {}).get(_frame, empty)
	$WorldCollisionArea.position.x = dir * ($AnimatedSprite2D.position.x + collision_rect.position.x + collision_rect.size.x / 2)

func _update_collision(collision_object, collision_rect):
	collision_object.disabled = not collision_rect.has_area()
	collision_object.position = Vector2(
		dir * ($AnimatedSprite2D.position.x + collision_rect.position.x + collision_rect.size.x / 2),
		collision_rect.position.y + collision_rect.size.y / 2)
	collision_object.shape.size = collision_rect.size

#region attack functions

func _get_acceptable_combo(comboables):
	for comboable in comboables:
		if action == comboable.animation and _frame in range(comboable.min_frame, comboable.max_frame):
			return comboable
	return false

func _attack_guard(comboables):
	if !landed: return false
	if hit: return false
	if walking:
		if action == "tsuisoku" and _frame > _4th: return false
		if action == "taisoku" and _frame > _4th: return false
		if action == "ushiro": return false
		if not _get_acceptable_combo(comboables): return false
	if attacking and not _get_acceptable_combo(comboables): return false
	return true

func _comboable_from(animation, min_frame, max_frame):
	return func(start_frame = 0, at_mid_combo = func (): pass):
		return {
			"animation": animation,
			"min_frame": min_frame,
			"max_frame": max_frame,
			"start_frame": start_frame,
			"at_mid_combo": at_mid_combo
		}

var _comboable_from_senten = _comboable_from("senten", _11th, _13th)
var _comboable_from_sentainotsuki = _comboable_from("sentainotsuki", _10th, _16th)
var _comboable_from_sensogeri = _comboable_from('sensogeri', _13th, _16th)
var _comboable_from_fujogeri = _comboable_from('fujogeri', _10th, _16th)
var _comboable_from_manjigeri = _comboable_from('manjigeri', _10th, _13th)
var _comboable_from_koten = _comboable_from('koten', _10th, _13th)

func _attack(animation, frame_changed = null, animation_finished = null):
	return func(comboables = []): if _attack_guard(comboables):
		attacking = true
		walking = false
		sounded = false
		velocity.x = 0
		var combo = _get_acceptable_combo(comboables)
		if combo:
			$AnimatedSprite2D.animation_finished.disconnect(_stand_at_end_of_action)
			$AnimatedSprite2D.emit_signal("animation_finished")
			$AnimatedSprite2D.animation_finished.connect(_stand_at_end_of_action)
			combo.at_mid_combo.call()
		_play_animation(animation)
		if combo: $AnimatedSprite2D.frame = combo.start_frame
		if frame_changed: $AnimatedSprite2D.frame_changed.connect(frame_changed)
		if animation_finished: $AnimatedSprite2D.animation_finished.connect(animation_finished, CONNECT_ONE_SHOT)

func _clear_frame_step_listeners():
	for connection in $AnimatedSprite2D.frame_changed.get_connections():
		if (connection.callable != _sound_missed_hit):
			$AnimatedSprite2D.frame_changed.disconnect(connection.callable)

func fujogeri():
	_attack("fujogeri", _fujogeri_step).call([
		_comboable_from_sentainotsuki.call(_3rd),
		_comboable_from_senten.call(_5th),
	])

func _fujogeri_step():
	if _frame > _4th:
		velocity.y = -jump_speed
		if $AnimatedSprite2D.frame_changed.is_connected(_fujogeri_step):
			$AnimatedSprite2D.frame_changed.disconnect(_fujogeri_step)

func fujogeri_forward():
	_attack("fujogeri", _fujogeri_forward_step).call([
		_comboable_from_sentainotsuki.call(_3rd),
		_comboable_from_senten.call(_5th),
	])

func _fujogeri_forward_step():
	if _frame > _4th and _frame < _7th:
		velocity.x = dir * speed
		velocity.y = -jump_speed
		if $AnimatedSprite2D.frame_changed.is_connected(_fujogeri_forward_step):
			$AnimatedSprite2D.frame_changed.disconnect(_fujogeri_forward_step)

func hangetsuate():
	_attack("hangetsuate").call([
		_comboable_from_manjigeri.call(_5th, func(): position.x += dir * 10),
		_comboable_from_koten.call(_5th, func(): _turn()),
		_comboable_from_senten.call(_5th),
	])

func sentainotsuki():
	_attack("sentainotsuki", null, _sentainotsuki_end).call([
		#_comboable_from_sensogeri.call(_6th),
		_comboable_from_manjigeri.call(_7th)
	])

func _sentainotsuki_end():
	position.x += dir * 15 * 2

func manjigeri():
	_attack("manjigeri").call([
		_comboable_from_fujogeri.call(_2nd),
		_comboable_from_koten.call(_4th, func(): _turn()),
		_comboable_from_senten.call(_4th),
	])

func suiheigeri():
	_attack("suiheigeri").call([
		_comboable_from_sensogeri.call(_4th, func(): position.x += dir * 4)
	])

func sensogeri():
	_attack("sensogeri").call([
		_comboable_from_manjigeri.call(_8th, func(): position.x += dir * 8),
		_comboable_from_koten.call(_8th, func(): _turn()),
		_comboable_from_senten.call(_8th)
	])

#endregion

#region unsoku functions

func stand():
	_play_animation("stand")
	velocity.x = 0
	walking = false
	attacking = false
	hit = false
	target = null

func _walk_guard():
	if hit: return false
	if !landed: return false
	if attacking: return false
	if walking: return false
	walking = true
	return walking

func ushiro(): if _walk_guard():
	_play_animation("ushiro")
	$AnimatedSprite2D.animation_finished.connect(_ushiro_end, CONNECT_ONE_SHOT)

func _ushiro_end():
	_turn()

func _turn():
	position.x += dir * 6
	dir = -dir
	if dir == 1:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.position.x = 0
	elif dir == -1:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.position.x = -48

func senten(): if _walk_guard():
	_play_animation("senten")
	$AnimatedSprite2D.frame_changed.connect(_senten_step)
	$AnimatedSprite2D.animation_finished.connect(_senten_end, CONNECT_ONE_SHOT)
	
func _senten_step():
	if _frame > _3rd:
		velocity.x = dir * speed * 2.5
	if _frame > _11th:
		velocity.x = dir

func _senten_end():
	velocity.x = dir
	if $AnimatedSprite2D.frame_changed.is_connected(_senten_step):
		$AnimatedSprite2D.frame_changed.disconnect(_senten_step)

func koten(): if _walk_guard():
	_play_animation("koten")
	$AnimatedSprite2D.frame_changed.connect(_koten_step)
	$AnimatedSprite2D.animation_finished.connect(_koten_end, CONNECT_ONE_SHOT)

func _koten_step():
	if _frame > _2nd:
		velocity.x = -dir * speed * 2.5
	if _frame > _12th:
		velocity.x = dir
	
func _koten_end():
	velocity.x = dir
	if $AnimatedSprite2D.frame_changed.is_connected(_koten_step):
		$AnimatedSprite2D.frame_changed.disconnect(_koten_step)

func kosoku(): if _walk_guard():
	_play_animation("kosoku")
	velocity.x = dir * speed/2.0
	
func gensoku(): if _walk_guard():
	_play_animation("kosoku")
	velocity.x = -dir * speed * 2/3.0
	
func ninoashi(): if _walk_guard():
	_play_animation("ninoashi")
	velocity.x = dir * speed/2.0

func tsuisoku(): if _walk_guard():
	_play_animation("tsuisoku")
	velocity.x = dir * speed

func taisoku(): if _walk_guard():
	_play_animation("taisoku")
	velocity.x = -dir * speed

#endregion

func _hit(attacker, is_head_hit):
	if (hit): return
	stand()
	hit = true
	[$Hit1Player, $Hit2Player, $Hit3Player, $Hit4Player].pick_random().play()
	if is_head_hit: _play_animation("hithead")
	else: _play_animation("hittorso")
	emit_signal("hit_success", attacker, self, is_head_hit)

func _on_body_hit(area: Area2D):
	[$HurtPlayer1, $HurtPlayer2, $HurtPlayer3].pick_random().play()
	var shape = area.shape_owner_get_owner(0)
	var attacker = shape.get_parent().get_parent()
	_hit(attacker, false)

func _on_head_hit(area: Area2D):
	var shape = area.shape_owner_get_owner(0)
	var attacker = shape.get_parent().get_parent()
	var force = {
		"fujogeri": 40,
		"manjigeri": 25,
		"sensogeri": 40,
		"suiheigeri": 35,
		"sentainotsuki": 25,
		"hangetsuate": 40
	}.get(attacker.action, 0)
	var is_head_shot = force > 35 and randf() > 0.75
	if is_head_shot: _heads_off(force)
	_hit(attacker, is_head_shot)

func _heads_off(force):
	[$HeadOffPlayer1, $HeadOffPlayer2, $HeadOffPlayer3].pick_random().play()
	var head = HeadScene.instantiate()
	call_deferred("add_child", head)
	head.apply_central_impulse(Vector2(dir * force * 5, -180))

func _sound_missed_hit():
	var attack_actions = ["fujogeri", "manjigeri", "sensogeri", "suiheigeri", "sentainotsuki", "hangetsuate"]
	if sounded == false and action in attack_actions:
		var frames = collisions.get(action, {}).get("hit", {}).values()
		var last_hit_frame = frames.map(func(c): return c.has_area()).rfind(true)
		if _frame > last_hit_frame:
			[$MissPlayer1, $MissPlayer1, $MissPlayer1, $MissPlayer1, $MissPlayer1, $MissPlayer1, $MissPlayer2].pick_random().play()
			sounded = true
	

func _stand_at_end_of_action():
	if action != "stand":
		stand()
