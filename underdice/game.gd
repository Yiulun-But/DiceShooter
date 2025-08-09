extends Node2D

@onready var enemy := preload("res://enemy.tscn")

var backgrounds: Array[Texture2D] = [
	preload("res://res/imgs/1.png"),
	preload("res://res/imgs/2.png"),
	preload("res://res/imgs/3.png"),
	preload("res://res/imgs/4.png"),
	preload("res://res/imgs/5.png"),
	preload("res://res/imgs/6.png")
]

func _on_timer_timeout() -> void:
		var new_obj = enemy.instantiate()
		add_child(new_obj)
		new_obj.position = Vector2(randf() * 400, randf() * 300)
		
		$Background.texture = backgrounds[randi_range(0, 5)]
