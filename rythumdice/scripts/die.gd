extends Node3D

@export var active: bool = false
@export var spawn_face: int = 1
@onready var material1: ShaderMaterial = $"1".get_active_material(0)
@onready var material2: ShaderMaterial = $"2".get_active_material(0)
@onready var material3: ShaderMaterial = $"3".get_active_material(0)
@onready var material4: ShaderMaterial = $"4".get_active_material(0)
@onready var material5: ShaderMaterial = $"5".get_active_material(0)
@onready var material6: ShaderMaterial = $"6".get_active_material(0)

var finished = false
var dicepos
var next
var camera

var target_rot : Quaternion
const ROT_SPEED = .3
var flash_tween: Tween
var current_flash_material: ShaderMaterial

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

func move_to_next():
	# disable controls for this dice and shift over to the next one
	if active:
		active = false
		dicepos.target_pos.x -= dicepos.DIE_SPACING
		
		# wait for the next frame before activating the next dice, prevents bug where they both rotate at once
		await get_tree().process_frame
		if next: next.active = true
		
func rot(axis, angle):
	var rotation_delta = Quaternion(axis, angle).normalized()
	target_rot = rotation_delta * target_rot

func _ready():
	camera     = get_tree().get_nodes_in_group("camera"  )[0]
	dicepos    = get_tree().get_nodes_in_group("levelgen")[0]
	
	# rotate so the correct face is up
	rotation   = face_rotations[spawn_face]
	target_rot = global_transform.basis.get_rotation_quaternion()

func _process(_delta):
	# interpolate rotation
	var current_rot = global_transform.basis.get_rotation_quaternion()
	current_rot     = current_rot.slerp(target_rot, ROT_SPEED)
	transform.basis = Basis(current_rot)
	
	# controls for rotating the dice
	if active:
		var camera_basis = camera.global_transform.basis
		if Input.is_action_just_pressed("up"   ): rot(camera_basis.x, -rot_angle)
		if Input.is_action_just_pressed("down" ): rot(camera_basis.x,  rot_angle)
		if Input.is_action_just_pressed("right"): rot(camera_basis.y,  rot_angle)
		if Input.is_action_just_pressed("left" ): rot(camera_basis.y, -rot_angle)

func _on_beat():
	move_to_next()
	
func set_flash_intensity(value: float):
	if current_flash_material:
		current_flash_material.set_shader_parameter("flash_intensity", value)
	
func flash_color(color: Color, material: ShaderMaterial, duration: float = 0.3):
	if flash_tween:
		flash_tween.kill()
	
	# Store which material we're flashing
	current_flash_material = material
	
	# Set the flash color
	material.set_shader_parameter("flash_color", Vector3(color.r, color.g, color.b))
	
	# Animate the flash intensity
	flash_tween = create_tween()
	flash_tween.tween_method(set_flash_intensity, 0.0, 1.0, duration * 0.3)
	flash_tween.tween_method(set_flash_intensity, 1.0, 0.0, duration * 0.7)

# Helper functions to flash specific faces
func flash_face_1(color: Color = Color.GREEN): flash_color(color, material1)
func flash_face_2(color: Color = Color.GREEN): flash_color(color, material2)
func flash_face_3(color: Color = Color.GREEN): flash_color(color, material3)
func flash_face_4(color: Color = Color.GREEN): flash_color(color, material4)
func flash_face_5(color: Color = Color.GREEN): flash_color(color, material5)
func flash_face_6(color: Color = Color.GREEN): flash_color(color, material6)

# Flash the current top face
func flash_current_face(color: Color = Color.GREEN):
	var materials = [material1, material2, material3, material4, material5, material6]
	flash_color(color, materials[spawn_face - 1])
