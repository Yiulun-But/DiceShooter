# StatsPanel.gd
extends Control

# UI Elements
@onready var stats_label: Label = $StatsLabel
@onready var attack_label: Label = $AttackStat/AttackLabel
@onready var attack_value: Label = $AttackStat/AttackValue
@onready var attack_button: Button = $AttackStat/AttackButton
@onready var movement_label: Label = $MovementStat/MovementLabel
@onready var movement_value: Label = $MovementStat/MovementValue
@onready var movement_button: Button = $MovementStat/MovementButton
@onready var defense_label: Label = $DefenseStat/DefenseLabel
@onready var defense_value: Label = $DefenseStat/DefenseValue
@onready var defense_button: Button = $DefenseStat/DefenseButton

# Stats values
var attack_stat: int = 0
var movement_stat: int = 0
var defense_stat: int = 0

# Available dice to assign
var available_dice: Array[int] = []

func _ready():
	setup_ui()
	connect_buttons()
	update_display()

func setup_ui():
	# Position in bottom-right corner
	size = Vector2(200, 180)
	position = Vector2(get_viewport().get_visible_rect().size.x - 210, 
					  get_viewport().get_visible_rect().size.y - 190)
	
	# Setup main label
	stats_label.text = "Character Stats"
	stats_label.size = Vector2(180, 20)
	stats_label.position = Vector2(10, 5)
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Setup Attack stat
	setup_stat_row($AttackStat, "Attack:", 30)
	
	# Setup Movement stat  
	setup_stat_row($MovementStat, "Movement:", 70)
	
	# Setup Defense stat
	setup_stat_row($DefenseStat, "Defense:", 110)

func setup_stat_row(stat_container: Control, label_text: String, y_pos: int):
	stat_container.size = Vector2(180, 30)
	stat_container.position = Vector2(10, y_pos)
	
	# Label (Attack:, Movement:, Defense:)
	var label = stat_container.get_child(0) as Label
	label.text = label_text
	label.size = Vector2(70, 20)
	label.position = Vector2(0, 5)
	label.add_theme_font_size_override("font_size", 12)
	
	# Value display (shows assigned dice value)
	var value = stat_container.get_child(1) as Label
	value.text = "0"
	value.size = Vector2(30, 20)
	value.position = Vector2(75, 5)
	value.add_theme_font_size_override("font_size", 12)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Assign button
	var button = stat_container.get_child(2) as Button
	button.text = "Assign"
	button.size = Vector2(60, 20)
	button.position = Vector2(110, 5)
	button.disabled = true  # Disabled until dice are available

func connect_buttons():
	attack_button.pressed.connect(_on_attack_assign_pressed)
	movement_button.pressed.connect(_on_movement_assign_pressed)
	defense_button.pressed.connect(_on_defense_assign_pressed)

func _on_attack_assign_pressed():
	assign_dice_to_stat("attack")

func _on_movement_assign_pressed():
	assign_dice_to_stat("movement")

func _on_defense_assign_pressed():
	assign_dice_to_stat("defense")

func assign_dice_to_stat(stat_name: String):
	if available_dice.is_empty():
		print("No dice available to assign!")
		return
	
	# Take the first available die
	var dice_value = available_dice.pop_front()
	
	# Assign to the specified stat
	match stat_name:
		"attack":
			attack_stat = dice_value
			print("Assigned ", dice_value, " to Attack")
		"movement":
			movement_stat = dice_value
			print("Assigned ", dice_value, " to Movement")
			# Notify player to update movement range
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.refresh_movement_range()
		"defense":
			defense_stat = dice_value
			print("Assigned ", dice_value, " to Defense")
	
	update_display()
	update_button_states()

func update_display():
	# Update stat value displays
	attack_value.text = str(attack_stat)
	movement_value.text = str(movement_stat)
	defense_value.text = str(defense_stat)
	
	# Update stats label to show available dice
	if available_dice.size() > 0:
		stats_label.text = "Available: " + str(available_dice)
	else:
		stats_label.text = "Character Stats"

func update_button_states():
	# Enable/disable buttons based on available dice
	var has_dice = available_dice.size() > 0
	attack_button.disabled = not has_dice
	movement_button.disabled = not has_dice
	defense_button.disabled = not has_dice
	
	# Update button text to show what dice value will be assigned
	if has_dice:
		var next_dice = available_dice[0]
		attack_button.text = "+" + str(next_dice)
		movement_button.text = "+" + str(next_dice)
		defense_button.text = "+" + str(next_dice)
	else:
		attack_button.text = "Assign"
		movement_button.text = "Assign"
		defense_button.text = "Assign"

# Call this when new dice are rolled
func receive_dice_results(dice_results: Array[int]):
	available_dice = dice_results.duplicate()  # Copy the array
	print("Received dice results: ", available_dice)
	update_display()
	update_button_states()

# Reset all stats
func reset_stats():
	attack_stat = 0
	movement_stat = 0
	defense_stat = 0
	available_dice.clear()
	update_display()
	update_button_states()

# Public getters for stats (for future use)
func get_attack() -> int:
	return attack_stat

func get_movement() -> int:
	return movement_stat

func get_defense() -> int:
	return defense_stat
