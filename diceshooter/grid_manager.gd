# GridManager.gd
extends Node2D

const TILE_SIZE = 64  # Size of each grid cell in pixels
var grid_width = 10
var grid_height = 8

func _ready():
	draw_grid()

# Convert grid coordinates (0,0), (1,0) etc. to world position
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE * 0.5, grid_pos.y * TILE_SIZE + TILE_SIZE * 0.5)

# Convert world position back to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))

# Check if a grid position is within bounds
func is_valid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_width and grid_pos.y >= 0 and grid_pos.y < grid_height

# Check if tile is occupied by a unit
func is_tile_occupied(grid_pos: Vector2i) -> bool:
	# For now, no tiles are occupied (we only have one player)
	return false

# Get valid movement tiles from position within range
func get_movement_tiles(start_pos: Vector2i, movement_range: int) -> Array[Vector2i]:
	var valid_tiles: Array[Vector2i] = []
	
	for x in range(start_pos.x - movement_range, start_pos.x + movement_range + 1):
		for y in range(start_pos.y - movement_range, start_pos.y + movement_range + 1):
			var tile_pos = Vector2i(x, y)
			var distance = abs(x - start_pos.x) + abs(y - start_pos.y)  # Manhattan distance
			
			if distance <= movement_range and is_valid_position(tile_pos) and not is_tile_occupied(tile_pos):
				valid_tiles.append(tile_pos)
	
	return valid_tiles

# Draw a simple grid for visualization
func draw_grid():
	# Create a simple visual grid using Line2D nodes
	for x in range(grid_width + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * TILE_SIZE, 0))
		line.add_point(Vector2(x * TILE_SIZE, grid_height * TILE_SIZE))
		line.default_color = Color.GRAY
		line.width = 1
		add_child(line)
	
	for y in range(grid_height + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * TILE_SIZE))
		line.add_point(Vector2(grid_width * TILE_SIZE, y * TILE_SIZE))
		line.default_color = Color.GRAY
		line.width = 1
		add_child(line)
