extends Control

@export var value: int = 0:
	set = _set_value

@export var color: String:
	set = _set_color

func _set_value(new_value):
	value = new_value
	queue_redraw()

func _set_color(new_color):
	color = new_color
	queue_redraw()

func _process(_delta):
	queue_redraw()

func _draw():
	var angle_from = -45
	var angle_to = angle_from + (90 * value if value else 0)
	_draw_circle_arc_poly(size / 2, size.x / 2 - 2, angle_from, angle_to)

func _draw_circle_arc_poly(center, radius, angle_from, angle_to):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var c = Color.from_string(color, "red")
	var colors = PackedColorArray([c])

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
