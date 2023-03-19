extends KinematicBody

var speed = 16 # The movement speed of the player in units per second
var gravity = -45 # The gravity force applied to the player in units per second squared
var jump_force = 30 # The upward force applied to the player when jumping in units per second
var mouse_sensitivity = 0.3 # The sensitivity of mouse input for camera rotation
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player
var target_velocity = Vector3.ZERO # A vector that stores the desired velocity of the player based on input
var acceleration = 4 #how fast to gain units/second
var jump_count = 0 #tracks current jumps
var max_jumps = 1 #max number of jumps
var air_jump_scale = 0.8 # strength of second+ jumps
var sensitivity = 0.2 #camera move sensitivity
var min_pitch = -25 #camera pitch max (up)
var max_pitch = 25 #camera pitch min (down)
var pitch = 15 #default cam pitch

onready var camera = $Camera # A reference to the Camera node child of Player
onready var animation_player = $AnimationPlayer # A reference to the AnimationPlayer node child of Player
onready var animation_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")


func _ready():
	state_machine.start("")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
pass


func _input(event):
	#CAMERA MOVEMENT
	if event is InputEventMouseMotion:
		var motion = event.relative
		rotate_y(deg2rad(-motion.x * sensitivity))
		pitch += motion.y * sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		camera.rotation.x = deg2rad(-pitch)
pass


func _physics_process(delta):
	#CHARACTER MOVEMENT LOGIC
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	direction = direction.normalized()
	direction = camera.global_transform.basis.xform(direction)
	target_velocity = speed * direction
	velocity = velocity.linear_interpolate(target_velocity, delta * acceleration)

	if not is_on_floor():
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)

#JUMPING LOGIC
# We check if we are on floor using KinematicBody's built-in method. 
	if is_on_floor():
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y += jump_force
	else:
		if jump_count < max_jumps - 1 and Input.is_action_just_pressed("jump"):
			jump_count += 1
			velocity.y += air_jump_scale * jump_force
	
	if direction.length() == 0:
		state_machine.travel("Idle")
		#animation_tree["parameters/state/current"] = 1
	else:
		state_machine.travel("Walk")
		#$AnimationPlayer.playback_speed = direction.length() * speed * 20
		#animation_tree["parameters/state/current"] = 0
	pass
