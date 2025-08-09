extends Area2D

func _draw():
	var shape = $CollisionShape2D.shape
	draw_circle(Vector2.ZERO, shape.radius, Color(1,0,0,0.5))
