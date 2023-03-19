extends KinematicBody

var speed = 10 # The movement speed of the player in units per second
var gravity = -20 # The gravity force applied to the player in units per second squared
var jump_force = 15 # The upward force applied to the player when jumping in units per second
var mouse_sensitivity = 0.3 # The sensitivity of mouse input for camera rotation
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player

onready var camera = $Camera # A reference to the Camera node child of Player
onready var animation_player = $AnimationPlayer # A reference to the AnimationPlayer node child of Player

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Capture mouse input so it doesn't move outside of game window
	
	pass

func _physics_process(delta):
	# Called every physics frame. Delta is time since last physics frame.
	# Implement physics-related logic here
	
	pass
