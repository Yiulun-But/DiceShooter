# Enemy.gd
extends Node2D

var grid_position: Vector2i = Vector2i(6, 4)  # Starting position (middle-right of grid)
var grid_manager: Node2D
var max_health: int = 999999  # Infinite health for dummy
var current_health: int = 999999
var is_dummy: bool = true  # Mark as dummy enemy

@onready var sprite = $Sprite2D
@onready var health_label = $HealthLabel

func _ready():
	grid_manager = get_parent().get_parent().get_parent().get_node("GridManager")  # Enemy is under Units/EnemyUnits
	
	# Setup sprite
	if sprite:
		print("Enemy sprite found!")
		
		# Center the sprite
		sprite.centered = true
		
		# Create a red square for enemy if no texture assigned
		if not sprite.texture:
			var image = Image.create(48, 48, false, Image.FORMAT_RGB8)
			image.fill(Color.RED)
			var texture = ImageTexture.new()
			texture.set_image(image)
			sprite.texture = texture
	
	# Setup health label
	if not health_label:
		health_label = Label.new()
		add_child(health_label)
	
	health_label.text = "HP: ∞"
	health_label.size = Vector2(60, 20)
	health_label.position = Vector2(-30, -40)  # Above the enemy
	health_label.add_theme_font_size_override("font_size", 10)
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Move to initial grid position
	update_world_position()
	
	print("Enemy positioned at: ", grid_position)

func take_damage(damage: int):
	# Dummy enemy takes damage but doesn't die
	print("Enemy takes ", damage, " damage! (Dummy enemy)")
	
	# Visual feedback - flash red
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	# Update health label to show damage taken
	var damage_text = "-" + str(damage)
	show_floating_damage(damage_text)

func show_floating_damage(damage_text: String):
	# Create floating damage number
	var damage_label = Label.new()
	damage_label.text = damage_text
	damage_label.add_theme_font_size_override("font_size", 14)
	damage_label.add_theme_color_override("font_color", Color.YELLOW)
	damage_label.position = Vector2(-15, -20)
	add_child(damage_label)
	
	# Animate floating damage
	var tween = create_tween()
	tween.parallel().tween_property(damage_label, "position", Vector2(-15, -60), 1.0)
	tween.parallel().tween_property(damage_label, "modulate", Color.TRANSPARENT, 1.0)
	tween.tween_callback(damage_label.queue_free)

func is_defeated() -> bool:
	# Dummy enemy never dies
	return false

func update_world_position():
	# Convert grid position to world position and move the enemy
	global_position = grid_manager.grid_to_world(grid_position)

func get_grid_position() -> Vector2i:
	return grid_position

func is_enemy() -> bool:
	return true

func is_player() -> bool:
	return false
