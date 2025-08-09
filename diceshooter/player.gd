# Player.gd
extends Node2D

var grid_position: Vector2i = Vector2i(2, 2)  # Starting position
var grid_manager: Node2D
var base_movement_range: int = 0  # Default movement when no dice assigned
var current_movement_range: int = 0  # Current movement range
var attack_range: int = 1  # Can attack adjacent tiles
var is_selected: bool = false  # Track if player is selected

@onready var sprite = $Sprite2D
var movement_tiles: Array[Vector2i] = []  # Valid movement positions
var movement_highlights: Array[Node2D] = []  # Visual highlights for movement
var attack_tiles: Array[Vector2i] = []  # Valid attack positions
var attack_highlights: Array[Node2D] = []  # Visual highlights for attacks
var stats_panel: Control  # Reference to stats panel
var is_in_attack_mode: bool = false  # Track if showing attack range

func _ready():
	grid_manager = get_parent().get_parent().get_parent().get_node("GridManager")
	stats_panel = get_tree().get_first_node_in_group("stats_panel")
	
	# Setup sprite
	if sprite:
		print("Sprite found!")
		print("Sprite texture: ", sprite.texture)
		
		# Center the sprite - this fixes the offset issue
		sprite.centered = true
		
		# Only create a texture if the sprite doesn't already have one
		if not sprite.texture:
			# Create a simple texture (colored rectangle) as fallback
			var image = Image.create(48, 48, false, Image.FORMAT_RGB8)
			image.fill(Color.BLUE)
			var texture = ImageTexture.new()
			texture.set_image(image)
			sprite.texture = texture
	else:
		print("ERROR: No Sprite2D found!")
	
	# Move to initial grid position
	update_world_position()
	
	# Debug: Print final position
	print("Player position: ", global_position)
	print("Grid position: ", grid_position)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Get mouse position in world coordinates
		var mouse_world_pos = get_global_mouse_position()
		
		# Convert to grid coordinates
		var clicked_grid_pos = grid_manager.world_to_grid(mouse_world_pos)
		
		# Check if we clicked on the player
		if clicked_grid_pos == grid_position:
			select_player()
		# If player is selected and in attack mode, try to attack
		elif is_selected and is_in_attack_mode:
			attempt_attack(clicked_grid_pos)
		# If player is selected and in movement mode, try to move
		elif is_selected and not is_in_attack_mode:
			attempt_move(clicked_grid_pos)
		# If clicking somewhere else while not selected, do nothing
		else:
			print("Click on the player first to select them")
	
	# Keyboard shortcuts
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# Roll dice when spacebar is pressed
			var dice_roller = get_tree().get_first_node_in_group("dice_roller")
			if dice_roller:
				dice_roller.roll_dice()
		elif event.keycode == KEY_A and is_selected:
			# Press 'A' to switch to attack mode
			toggle_attack_mode()

func select_player():
	if is_selected:
		# Already selected, deselect
		deselect_player()
	else:
		# Select the player and show movement range
		is_selected = true
		is_in_attack_mode = false
		sprite.modulate = Color.YELLOW  # Change color to show selection
		update_movement_range()  # Calculate current movement range
		show_movement_range()
		print("Player selected! Movement range: ", current_movement_range, " | Press 'A' to attack")

func deselect_player():
	is_selected = false
	is_in_attack_mode = false
	sprite.modulate = Color.WHITE  # Return to normal color
	hide_movement_range()
	hide_attack_range()
	print("Player deselected")

func toggle_attack_mode():
	if not is_selected:
		return
	
	is_in_attack_mode = not is_in_attack_mode
	
	if is_in_attack_mode:
		hide_movement_range()
		show_attack_range()
		sprite.modulate = Color.ORANGE  # Orange for attack mode
		print("Attack mode! Click on red tiles to attack")
	else:
		hide_attack_range()
		show_movement_range()
		sprite.modulate = Color.YELLOW  # Yellow for movement mode
		print("Movement mode! Click on green tiles to move")

func update_movement_range():
	# Get movement stat from stats panel
	var movement_stat = 0
	if stats_panel:
		movement_stat = stats_panel.get_movement()
	
	# SET movement range to dice value, or use base if no dice assigned
	if movement_stat > 0:
		current_movement_range = movement_stat  # Use dice value directly
		print("Movement SET to dice value: ", movement_stat)
	else:
		current_movement_range = base_movement_range  # Use default when no dice
		print("Movement using default: ", base_movement_range)
	
	# Ensure minimum movement of 1
	current_movement_range = max(0, current_movement_range)

func attempt_move(target_pos: Vector2i):
	# Check if the clicked position is valid and within movement range
	if target_pos in movement_tiles:
		grid_position = target_pos
		update_world_position()
		deselect_player()  # Auto-deselect after moving
		print("Player moved to: ", grid_position)
	else:
		if not grid_manager.is_valid_position(target_pos):
			print("Invalid position: ", target_pos)
		else:
			print("Can't move there! Click on a highlighted tile")

func attempt_attack(target_pos: Vector2i):
	print("Attempting to attack position: ", target_pos)
	
	# Check if the clicked position is valid for attack
	if target_pos in attack_tiles:
		print("Position is in attack range")
		
		# Find enemy at target position
		var enemy = find_unit_at_position(target_pos)
		if enemy:
			print("Found unit: ", enemy.name, " at position: ", enemy.get_grid_position())
			if enemy.has_method("is_enemy") and enemy.is_enemy():
				print("Unit is an enemy - attacking!")
				perform_attack(enemy)
			else:
				print("Unit is not an enemy")
		else:
			print("No unit found at position: ", target_pos)
			# Debug: List all units and their positions
			list_all_units()
	else:
		print("Can't attack there! Position not in attack range")
		print("Valid attack positions: ", attack_tiles)

func perform_attack(enemy):
	# Get attack stat from stats panel
	var attack_damage = 10  # Base damage
	if stats_panel:
		var attack_stat = stats_panel.get_attack()
		if attack_stat > 0:
			attack_damage = attack_stat  # Use dice value as damage
	
	print("Attacking with ", attack_damage, " damage!")
	enemy.take_damage(attack_damage)
	
	# Don't deselect after attack, allow multiple attacks
	print("Attack complete! Press 'A' again to switch to movement")

func show_movement_range():
	# Calculate all valid movement positions using current movement range
	movement_tiles = grid_manager.get_movement_tiles(grid_position, current_movement_range)
	
	# Create visual highlights for each valid tile
	for tile_pos in movement_tiles:
		if tile_pos != grid_position:  # Don't highlight current position
			create_movement_highlight(tile_pos)
	
	print("Showing ", movement_tiles.size(), " movement tiles with range ", current_movement_range)

func show_attack_range():
	# Calculate all valid attack positions
	attack_tiles = grid_manager.get_movement_tiles(grid_position, attack_range)
	
	# Create visual highlights for each valid attack tile
	for tile_pos in attack_tiles:
		if tile_pos != grid_position:  # Don't highlight current position
			create_attack_highlight(tile_pos)
	
	print("Showing attack range with range ", attack_range)

func hide_movement_range():
	# Remove all movement highlights
	for highlight in movement_highlights:
		highlight.queue_free()
	movement_highlights.clear()
	movement_tiles.clear()

func hide_attack_range():
	# Remove all attack highlights
	for highlight in attack_highlights:
		highlight.queue_free()
	attack_highlights.clear()
	attack_tiles.clear()

func create_movement_highlight(tile_pos: Vector2i):
	# Create a visual highlight for a movement tile (green)
	var highlight = Node2D.new()
	var highlight_sprite = Sprite2D.new()
	highlight.add_child(highlight_sprite)
	
	# Create a semi-transparent green square
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 1, 0, 0.5))  # Green with 50% transparency
	var texture = ImageTexture.new()
	texture.set_image(image)
	highlight_sprite.texture = texture
	highlight_sprite.centered = true
	
	# Position the highlight
	highlight.global_position = grid_manager.grid_to_world(tile_pos)
	
	# Add to scene and track it
	get_parent().add_child(highlight)
	movement_highlights.append(highlight)

func create_attack_highlight(tile_pos: Vector2i):
	# Create a visual highlight for an attack tile (red)
	var highlight = Node2D.new()
	var highlight_sprite = Sprite2D.new()
	highlight.add_child(highlight_sprite)
	
	# Create a semi-transparent red square
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 0, 0, 0.5))  # Red with 50% transparency
	var texture = ImageTexture.new()
	texture.set_image(image)
	highlight_sprite.texture = texture
	highlight_sprite.centered = true
	
	# Position the highlight
	highlight.global_position = grid_manager.grid_to_world(tile_pos)
	
	# Add to scene and track it
	get_parent().add_child(highlight)
	attack_highlights.append(highlight)

func find_unit_at_position(pos: Vector2i):
	print("Looking for unit at: ", pos)
	
	# Look directly in Units container (your current structure)
	var units_container = get_parent().get_parent().get_parent().get_node("Units")
	if units_container:
		print("Found Units container: ", units_container.name)
		for unit in units_container.get_node("EnemyUnits").get_children():
			print("Checking unit: ", unit.name)
			if unit.has_method("get_grid_position"):
				var unit_pos = unit.get_grid_position()
				print("Unit ", unit.name, " at position: ", unit_pos)
				if unit_pos == pos:
					print("Found matching unit!")
					return unit
			else:
				print("Unit ", unit.name, " doesn't have get_grid_position method")
	else:
		print("Units container not found!")
	return null
	
func list_all_units():
	print("=== ALL UNITS DEBUG ===")
	var units_container = get_parent().get_parent().get_node("Units")
	if units_container:
		for unit_group in units_container.get_children():
			print("Group: ", unit_group.name)
			for unit in unit_group.get_children():
				if unit.has_method("get_grid_position"):
					print("  - ", unit.name, " at ", unit.get_grid_position())
	print("=====================")

func update_world_position():
	# Convert grid position to world position and move the player
	global_position = grid_manager.grid_to_world(grid_position)

# Public function to refresh movement range (call this when stats change)
func refresh_movement_range():
	if is_selected and not is_in_attack_mode:
		hide_movement_range()
		update_movement_range()
		show_movement_range()

func is_enemy() -> bool:
	return false

func is_player() -> bool:
	return true

func get_grid_position() -> Vector2i:
	return grid_position
