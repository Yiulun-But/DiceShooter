extends CanvasLayer

func _on_button1_pressed():
	global.selected_level = "res://levels/tetris.json"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button2_pressed():
	global.selected_level = "res://levels/tetris2.json"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button3_pressed():
	global.selected_level = "res://levels/level3.json"
	get_tree().change_scene_to_file("res://scenes/game.tscn")
