extends Camera3D

@export var desired_fov: float = 45.0  # Set your desired FOV here

func _ready():
	fov = desired_fov
	current = true
	
	# Double-check it applied
	print("Camera FOV set to: ", fov)

# Optional: Prevent FOV changes during runtime
func _process(delta):
	if fov != desired_fov:
		print("FOV changed! Resetting from ", fov, " to ", desired_fov)
		fov = desired_fov
