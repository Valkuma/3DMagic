extends KinematicBody
var health=10
#var types=[]
var speed = 16 # The movement speed of the player in units per second
var gravity = -65 # The gravity force applied to the player in units per second squared
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player
var target_velocity = Vector3.ZERO # A vector that stores the desired velocity of the player based on input
var acceleration = 3 #how fast to gain units/second


func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP,false,4,0.785398,false)
	pass
