extends Node

@export var collisions = {
	"fujogeri": build_collisions("res://assets/fujogeri-collisions.png"),
	"hangetsuate": build_collisions("res://assets/hangetsuate-collisions.png"),
	"kosoku": build_collisions("res://assets/kosoku-collisions.png"),
	"koten": build_collisions("res://assets/koten-collisions.png"),
	"manjigeri": build_collisions("res://assets/manjigeri-collisions.png"),
	"ninoashi": build_collisions("res://assets/ninoashi-collisions.png"),
	"sensogeri": build_collisions("res://assets/sensogeri-collisions.png"),
	"sentainotsuki": build_collisions("res://assets/sentainotsuki-collisions.png"),
	"senten": build_collisions("res://assets/senten-collisions.png"),
	"suiheigeri": build_collisions("res://assets/suiheigeri-collisions.png"),
	"stand": build_collisions("res://assets/tsuisoku-collisions.png"),
	"taisoku": reverse_collisions(build_collisions("res://assets/tsuisoku-collisions.png")),
	"tsuisoku": build_collisions("res://assets/tsuisoku-collisions.png"),
	"ushiro": build_collisions("res://assets/ushiro-collisions.png"),
}

func find_color_rect(data, red_color, tilew):
	const feather = 4
	var lookup_color = red_color - feather
	var result = Rect2i()
	while lookup_color < red_color + feather:
		var aix = data.find(lookup_color)
		var a = aix / 4
		var bix = data.rfind(lookup_color)
		var b = bix / 4
		lookup_color += 1
		if aix > -1:
			result.position = Vector2i(a % tilew, floor(a / tilew))
			result.size = Vector2i(b % tilew - result.position.x, floor(b / tilew) - result.position.y)
			return result
	return result
	
func build_collisions(res_path, tilew = 96, tileh = 64):
	var collision = { "head": {}, "torso": {}, "hit": {}, "body": {} }
	var image = load(res_path)
	
	for x in range(0, image.data.width, tilew):
		var frame = image.get_region(Rect2i(x, 0, tilew, tileh))
		var data = frame.get_data()
		collision.head[collision.head.size()] = find_color_rect(data, 150, tilew)
		collision.torso[collision.torso.size()] = find_color_rect(data, 200, tilew)
		collision.hit[collision.hit.size()] = find_color_rect(data, 100, tilew)
		collision.body[collision.body.size()] = frame.get_used_rect()
		
	return collision

func reverse_collisions(reversable):
	var result = { "head": {}, "torso": {}, "hit": {}, "body": {} }
	for key in result:
		var collision_frames = reversable.get(key)
		for frame in collision_frames:
			result[key][collision_frames.size() - frame] = collision_frames[frame]
	return result
