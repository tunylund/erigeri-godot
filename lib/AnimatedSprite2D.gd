extends AnimatedSprite2D

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

func prev_color(data, index):
	return get_color(data, index - 4)

func next_color(data, index):
	return get_color(data, index + 4)

func diff_int(a, b):
	return min(a, b) + (abs(min(a, b) - max(a, b)) / 2).floor()

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

func blur_pass(rnge: Range, a_data, b_data, i_data, adjacent_color_fn, tile_w):
	for i in rnge:
		if is_transparent(a_data, i) and is_transparent(b_data, i): return
		var ic = get_color(i_data, i)
		var adjc = adjacent_color_fn.call(i_data, i, tile_w)
		if is_darker(adjc, ic): set_color(diff_color(BLACK, ic), i_data, i)

func weigh_pass(rnge: Range, o_data, i_data, adjacent_color_fn, tilew):
	for i in rnge:
		if is_transparent(o_data, i): return
		var ic = get_color(i_data, i)
		var adjc = adjacent_color_fn.call(i_data, i, tilew)
		if is_darker(adjc, ic): set_color(diff_color(BLACK, ic), i_data, i)

func _ready():
	pass

func mn2mx(max, inc, fn):
	for i in range(0, max, inc):
		fn.call(i)
		
func interpolate(sprite_frames: SpriteFrames, name: String, tilew, tileh, pass_count):
	var result = Array.new()

	var j = 0
	for i in range(sprite_frames.get_frame_count(name)):
		var a = sprite_frames.get_frame_texture(name, i).get_image()
		var b = sprite_frames.get_frame_texture(name, i + 1).get_image()
		var a_data = a.get_data()
		var b_data = b.get_data()
		var i_data = PackedByteArray.new()
	
		diff_pass(aData, bData, iData)
		
		for k in range(2): blur_pass(range(0, i_data.length, 4), a_data, b_data, i_data, next_color, tilew)
		for k in range(2): blur_pass(range(i_data.length, 0, -4), a_data, b_data, i_data, prev_color, tilew)
		for k in range(2): blur_pass(range(0, i_data.length, 4), a_data, b_data, i_data, next_row_color, tilew)
		for k in range(2): blur_pass(range(i_data.length, 0, -4), a_data, b_data, i_data, prev_row_color, tilew)
		
		if pass_count % 2 != 0:
			if (j % 2 == 0):
				for k in range(2): weigh_pass(range(0, i_data.length, 4), a_data, i_data, next_color, tilew)
				for k in range(2): weigh_pass(range(i_data.length, 0, -4), a_data, i_data, prev_color, tilew)
				for k in range(2): weigh_pass(range(0, i_data.length, 4), a_data, i_data, next_row_color, tilew)
				for k in range(2): weigh_pass(range(i_data.length, 0, -4), a_data, i_data, prev_row_color, tilew)
			else:
				for k in range(2): weigh_pass(range(0, i_data.length, 4), b_data, i_data, prev_color, tilew)
				for k in range(2): weigh_pass(range(i_data.length, 0, -4), b_data, i_data, next_color, tilew)
				for k in range(2): weigh_pass(range(0, i_data.length, 4), b_data, i_data, prev_row_color, tilew)
				for k in range(2): weigh_pass(range(i_data.length, 0, -4), b_data, i_data, next_row_color, tilew)
		j = j+1
		
		result.append(a)
		result.append(Image.create_from_data(a.width, a.height, false, a.format, i_data))

	return canvas


