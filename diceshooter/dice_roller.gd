# DiceRoller.gd
extends Control

@onready var roll_button: Button = $RollButton
@onready var dice_result: Label = $DiceResult
@onready var dice_display: Label = get_parent().get_node("DiceDisplay")

var dice_sides: int = 6  # Standard 6-sided die
var roll_history: Array[int] = []  # Store the 3 dice rolls
var current_roll_count: int = 0

func _ready():
	# Set up the dice roller UI
	setup_ui()
	
	# Connect the button signal
	roll_button.pressed.connect(_on_roll_button_pressed)
	
	# Initialize display
	update_dice_display()

func setup_ui():
	# Position the roll button and result label
	size = Vector2(200, 80)
	position = Vector2(10, 10)  # Top-left corner
	
	# Setup roll button
	roll_button.text = "Roll Dice"
	roll_button.size = Vector2(80, 30)
	roll_button.position = Vector2(10, 10)
	
	# Setup result label (shows detailed info)
	dice_result.text = "Click to roll 3 dice!"
	dice_result.size = Vector2(180, 30)
	dice_result.position = Vector2(10, 45)
	dice_result.add_theme_font_size_override("font_size", 12)
	
	# Setup main display label (top-right corner) - make it bigger for 3 rolls
	dice_display.text = "Rolls: --"
	dice_display.size = Vector2(150, 80)  # Made bigger for multiple lines
	dice_display.position = Vector2(get_viewport().get_visible_rect().size.x - 160, 10)
	dice_display.add_theme_font_size_override("font_size", 14)
	dice_display.add_theme_color_override("font_color", Color.WHITE)
	dice_display.vertical_alignment = VERTICAL_ALIGNMENT_TOP  # Align text to top

func _on_roll_button_pressed():
	roll_dice()

func roll_dice():
	# Roll three separate dice
	roll_history.clear()
	
	# Roll 3 times
	for i in range(3):
		var new_roll = randi() % dice_sides + 1
		roll_history.append(new_roll)
	
	# Update displays
	dice_result.text = "Rolled 3 dice: " + str(roll_history)
	update_dice_display()
	
	# Send dice results to stats panel
	var stats_panel = get_tree().get_first_node_in_group("stats_panel")
	if stats_panel:
		stats_panel.receive_dice_results(roll_history)
	
	# Add some visual feedback
	animate_roll()
	
	print("Three rolls: ", roll_history)

func update_dice_display():
	if roll_history.size() > 0:
		var display_text = "3 Dice Rolls:\n"
		
		# Show each of the 3 rolls
		for i in range(roll_history.size()):
			display_text += "Roll " + str(i + 1) + ": " + str(roll_history[i]) + "\n"
		
		# Add total
		var total = 0
		for roll in roll_history:
			total += roll
		display_text += "Total: " + str(total)
		
		dice_display.text = display_text
	else:
		dice_display.text = "Rolls: --\nClick to roll!"

func animate_roll():
	# Simple animation - make the display flash
	var tween = create_tween()
	tween.tween_property(dice_display, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(dice_display, "modulate", Color.WHITE, 0.1)
	tween.tween_property(dice_display, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(dice_display, "modulate", Color.WHITE, 0.1)

# Public function to get the roll history
func get_roll_history() -> Array[int]:
	return roll_history

# Public function to get total of all rolls
func get_total() -> int:
	var total = 0
	for roll in roll_history:
		total += roll
	return total

# Public function to get the latest roll
func get_latest_roll() -> int:
	if roll_history.size() > 0:
		return roll_history[-1]
	return 0

# Function to clear roll history
func clear_rolls():
	roll_history.clear()
	current_roll_count = 0
	dice_result.text = "Rolls cleared!"
	update_dice_display()

# Function to change dice settings
func set_dice_config(sides: int, max_roll_count: int = 3):
	dice_sides = sides
	dice_result.text = "Ready to roll d" + str(sides)
