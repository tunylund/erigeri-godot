extends RigidBody2D

var screen_size

func _ready():
	screen_size = get_viewport_rect()

func _draw():
	draw_circle(Vector2.ZERO, $CollisionShape2D.shape.radius, Color.BLACK)
	
func _integrate_forces(_state):
	if not screen_size.has_point(global_position):
		queue_free()
		
