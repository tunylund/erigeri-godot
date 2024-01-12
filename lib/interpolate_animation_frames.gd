@tool
extends EditorScript

const TRANSPARENT = Color(0, 0, 0, 0)
const BLACK = Color(0, 0, 0, 255)

func get_color(data, index):
	if index < 0 or index >= data.size():
		return TRANSPARENT
	else:
		return Color(data[index], data[index + 1], data[index + 2], data[index + 3])

func set_color(color, data, index):
	data[index] = color.r
	data[index + 1] = color.g
	data[index + 2] = color.b
	data[index + 3] = color.a

func prev_row_color(data, index, tilew):
	return get_color(data, index - tilew * 4)

func next_row_color(data, index, tilew):
	return get_color(data, index + tilew * 4)

func prev_color(data, index, tilew = 0):
	return get_color(data, index - 4)

func next_color(data, index, tilew = 0):
	return get_color(data, index + 4)

func diff_int(a, b):
	return min(a, b) + floor(abs(min(a, b) - max(a, b)) / 2)

func diff_color(a, b):
	return Color(
		diff_int(a.r, b.r),
		diff_int(a.g, b.g),
		diff_int(a.b, b.b),
		diff_int(a.a, b.a)
	)

func is_transparent(data, index):
	return data[index + 3] == 0

func is_darker(a, b):
	return a.a > b.a

func mn2mx(max, inc, fn):
	for i in range(0, max, inc):
		fn.call(i)

func mx2mn(max, inc, fn):
	for i in range(max, 0, -inc):
		fn.call(i)

func dw2up(w, h, col, fn):
	for x in range(w):
		for y in range(h - 1, -1, -1):
			fn.call(x * col + y * col * w)

func up2dw(w, h, col, fn):
	for x in range(w):
		for y in range(h):
			fn.call(x * col + y * col * w)

func clone_pass(a_data, i_data):
	for i in range(a_data.size()):
		i_data[i] = a_data[i]

func diff_pass(a_data, b_data, i_data):
	for i in range(0, i_data.size(), 4):
		var ic = TRANSPARENT if is_transparent(a_data, i) or is_transparent(b_data, i) else BLACK
		set_color(ic, i_data, i)

func blur_pass(rnge, a_data, b_data, i_data, adjacent_color_fn, tile_w):
	#print("blurpass of ", rnge.front(), "-", rnge.back(), " (", rnge.size(), ") using ", adjacent_color_fn)
	for i in rnge:
		if is_transparent(a_data, i) and is_transparent(b_data, i): continue
		var ic = get_color(i_data, i)
		var adjc = adjacent_color_fn.call(i_data, i, tile_w)
		if is_darker(adjc, ic): set_color(diff_color(BLACK, ic), i_data, i)

func weigh_pass(rnge, o_data, i_data, adjacent_color_fn, tilew):
	#print("weighpass of ", rnge.front(), "-", rnge.back(), " (", rnge.size(), ") using ", adjacent_color_fn)
	for i in rnge:
		if is_transparent(o_data, i): continue
		var ic = get_color(i_data, i)
		var adjc = adjacent_color_fn.call(i_data, i, tilew)
		if is_darker(adjc, ic): set_color(diff_color(BLACK, ic), i_data, i)
		
func interpolate(frames: Array, pass_count):
	var result = Array()

	var j = 0
	for i in range(frames.size() - 1):
		var a = frames[i]
		var b = frames.front() if a == frames.back() else frames[i + 1]
		var tilew = a.get_width()
		var tileh = a.get_height()
		var a_data = a.get_data()
		var b_data = b.get_data()
		var i_data = PackedByteArray()
		i_data.resize(a_data.size())
		i_data.fill(0)
		
		print("creating an interpolation of frames ", i, " and ", i+1, " ", a, " and ", b, " width ", tilew, " height ", tileh, " bytes ", i_data.size())
		diff_pass(a_data, b_data, i_data)
		
		for k in range(2): blur_pass(range(0, i_data.size(), 4), a_data, b_data, i_data, next_color, tilew)
		for k in range(2): blur_pass(range(i_data.size()-4, 0, -4), a_data, b_data, i_data, prev_color, tilew)
		for k in range(2): blur_pass(range(0, i_data.size(), 4), a_data, b_data, i_data, next_row_color, tilew)
		for k in range(2): blur_pass(range(i_data.size()-4, 0, -4), a_data, b_data, i_data, prev_row_color, tilew)
		
		if (pass_count != 0):
			if (j % 2 == 0):
				for k in range(2): weigh_pass(range(0, i_data.size(), 4), a_data, i_data, next_color, tilew)
				for k in range(2): weigh_pass(range(i_data.size()-4, 0, -4), a_data, i_data, prev_color, tilew)
				for k in range(2): weigh_pass(range(0, i_data.size(), 4), a_data, i_data, next_row_color, tilew)
				for k in range(2): weigh_pass(range(i_data.size()-4, 0, -4), a_data, i_data, prev_row_color, tilew)
			else:
				for k in range(2): weigh_pass(range(0, i_data.size(), 4), b_data, i_data, prev_color, tilew)
				for k in range(2): weigh_pass(range(i_data.size()-4, 0, -4), b_data, i_data, next_color, tilew)
				for k in range(2): weigh_pass(range(0, i_data.size(), 4), b_data, i_data, prev_row_color, tilew)
				for k in range(2): weigh_pass(range(i_data.size()-4, 0, -4), b_data, i_data, next_row_color, tilew)
		j = j+1
		
		result.append(a)
		result.append(Image.create_from_data(tilew, tileh, false, a.get_format(), i_data))

	result.append(frames.back())
	return result

func interpolate_animation(sprite_frames, animation_name): 
	var interpolation_multiplier = 4
	var animation_name_i = animation_name + "_i"
	if (sprite_frames.has_animation(animation_name_i)):
		sprite_frames.remove_animation(animation_name_i)
	sprite_frames.add_animation(animation_name + "_i")

	var initial_frames = []
	for i in range(sprite_frames.get_frame_count(animation_name)):
		initial_frames.append(sprite_frames.get_frame_texture(animation_name, i).get_image())

	print("interpolating ", animation_name, " with ", initial_frames.size(), " frames")

	var result_pass_0 = interpolate(initial_frames, 0)
	var result_pass_1 = interpolate(result_pass_0, 1)

	print("result of ", animation_name, " contains ", result_pass_1.size(), " frames")

	for frame_image in result_pass_1:
		var ix = floor(result_pass_1.find(frame_image) / interpolation_multiplier)
		var duration = sprite_frames.get_frame_duration(animation_name, ix)
		sprite_frames.add_frame(
			animation_name_i,
			ImageTexture.create_from_image(frame_image),
			duration)
		sprite_frames.set_animation_loop(animation_name_i, sprite_frames.get_animation_loop(animation_name))
		sprite_frames.set_animation_speed(animation_name_i, sprite_frames.get_animation_speed(animation_name) * interpolation_multiplier)

func _run():
	var all_children = get_scene().get_children()
	for node in all_children:
		if node is AnimatedSprite2D:
			var sprite_frames = node.sprite_frames
			for animation_name in sprite_frames.get_animation_names():
				if animation_name.ends_with("_i"): continue
				interpolate_animation(sprite_frames, animation_name)
