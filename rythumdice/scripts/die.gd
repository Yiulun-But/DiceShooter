extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1

var finished = false
var dicepos
var next
var camera
var bgm

var target_rot : Quaternion
var target_pos : Vector3

var record_input = false
var recording_length = 128
var recorded_input = []
var row = 0

# list of (euclidean) rotations needed for each number to be on top
var rot_angle = deg_to_rad(90)
var face_rotations = {
	1: Vector3(0,           0, 0),
	2: Vector3(rot_angle,   0, 0),
	3: Vector3(0, 0,  -rot_angle),
	4: Vector3(0, 0,   rot_angle),
	5: Vector3( -rot_angle, 0, 0),
	6: Vector3(2*rot_angle, 0, 0),
}

func record_move():
	if not record_input: return
	if bgm.next_beat - 1 >= recording_length: return
	recorded_input[bgm.next_beat - 1] = row
	print(recorded_input)

func _jump(new_row):
	target_pos.z = -new_row * config.row_height
	row = new_row
	record_move()
	

func move_to_next():
	# disable controls for this dice and shift over to the next one
	if active:
		active = false
		dicepos.target_pos.x -= dicepos.die_spacing
		
		# wait for the next frame before activating the next dice, prevents bug where they both rotate at once
		await get_tree().process_frame
		if next: next.active = true
		
func rot(axis, angle):
	var rotation_delta = Quaternion(axis, angle).normalized()
	target_rot = rotation_delta * target_rot

func _ready():
	add_to_group("player")
	camera     = get_tree().get_nodes_in_group("camera"  )[0]
	dicepos    = get_tree().get_nodes_in_group("levelgen")[0]
	bgm        = get_tree().get_nodes_in_group("bgm"     )[0]
	
	signals.connect("_player_jump", Callable(self, "_jump"))
	
	for i in range(recording_length): recorded_input.append(null)
	
	# rotate so the correct face is up
	rotation   = face_rotations[spawn_face]
	target_rot = global_transform.basis.get_rotation_quaternion()
	target_pos = position

func _process(_delta):
	if Input.is_action_just_pressed("restart_game"):
		get_tree().reload_current_scene() 
		
	# interpolate rotation
	var current_rot = global_transform.basis.get_rotation_quaternion()
	current_rot     = current_rot.slerp(target_rot, config.dice_speed)
	transform.basis = Basis(current_rot)
	
	# interpolate position
	position = lerp(position, target_pos, config.dice_speed)
	
	# controls for rotating the dice
	if active:
		var camera_basis = camera.global_transform.basis
		if Input.is_action_just_pressed("up"   ): 
			rot(camera_basis.x, -rot_angle)
			target_pos.z -= config.row_height
			row += 1
			record_move()
			
		if Input.is_action_just_pressed("down" ): 
			rot(camera_basis.x,  rot_angle)
			target_pos.z += config.row_height
			row -= 1
			record_move()
			

func _on_beat():
	move_to_next()
