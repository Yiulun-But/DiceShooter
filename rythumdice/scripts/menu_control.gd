extends CanvasLayer

func _on_button1_pressed():
	global.selected_level = "res://levels/tetris.json"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button2_pressed():
	pass # Replace with function body.

func _on_button3_pressed():
	pass # Replace with function body.
