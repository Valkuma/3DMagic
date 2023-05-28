extends KinematicBody
export var maxhealth = 20
export var health = 20
signal hitSignal(oldhealth,newhealth,totaldmg)
signal deathsignal(health,killer,dmg)

var killer = "Unknown"
var lastHit = {"unknown":0}
var speed = 16 # The movement speed of the player in units per second
var gravity = -65 # The gravity force applied to the player in units per second squared
var jump_force = 15 # The upward force applied to the player when jumping in units per second
var mouse_sensitivity = 0.3 # The sensitivity of mouse input for camera rotation
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player
var target_velocity = Vector3.ZERO # A vector that stores the desired velocity of the player based on input
var acceleration = 3 #how fast to gain units/second
var jump_count = 0 #tracks current jumps
var max_jumps = 2 #max number of jumps
var jump_lerp_speed = 100  # Adjust this value to control the smoothness of the jump, miliseconds?
var air_jump_scale = 0.8 # strength of second+ jumps
var sensitivity = 0.2 #camera move sensitivity
var min_pitch = -25 #camera pitch max (up)
var max_pitch = 25 #camera pitch min (down)
var pitch = 15 #default cam pitch
#DEBUG VAR
var lasthreset

#OSD INPUTS
onready var osd_boxes = {
	KEY_W: $DebugUIContainer/w,
	KEY_S: $DebugUIContainer/s,
	KEY_A: $DebugUIContainer/a,
	KEY_D: $DebugUIContainer/d,
	KEY_SPACE: $DebugUIContainer/jumpu,
	BUTTON_LEFT: $DebugUIContainer/m1,
	BUTTON_RIGHT: $DebugUIContainer/m2,
}

onready var camera = $Camera # A reference to the Camera node child of Player
onready var animation_player = $AnimationPlayer # A reference to the AnimationPlayer node child of Player
onready var animation_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")

func _ready():
	state_machine.start("")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_parent().add_to_group("player")
pass


func _input(event):
	#CAMERA MOVEMENT
	if event is InputEventMouseMotion:
		var motion = event.relative
		rotate_y(deg2rad(-motion.x * sensitivity))
		pitch += motion.y * sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		camera.rotation.x = deg2rad(-pitch)
	#OSD INPUT
	if event is InputEventKey:
		var key = event.scancode
		if key in osd_boxes:
			var box = osd_boxes[key]
			
			box.color = (Color(.5, .1, .1) if event.pressed else Color(0, 0, 0))
	if event is InputEventMouseButton:
		var key = event.button_index
		if key in osd_boxes:
			var box = osd_boxes[key]
			
			box.color = (Color(.5, .1, .1) if event.pressed else Color(0, 0, 0))
pass


func _physics_process(delta):
	if (health <= 0):
		timeToDie(health)
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
	if Input.is_action_pressed("escape"):
		get_tree().quit()

	direction = direction.normalized()
	#New code to fix the slowdown issue only transform direction based on horizontal camera not vertical
	var horizontal_direction = Vector3(direction.x, 0, direction.z)
	horizontal_direction = camera.global_transform.basis.xform(horizontal_direction)
	direction = Vector3(horizontal_direction.x, direction.y, horizontal_direction.z)
	#direction = camera.global_transform.basis.xform(direction)
	target_velocity = speed * direction
	velocity = velocity.linear_interpolate(target_velocity, delta * acceleration)

	#if not is_on_floor():
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP,false,4,0.785398,false)

	#JUMPING LOGIC
	if is_on_floor():
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = lerp(velocity.y, jump_force, delta * jump_lerp_speed)
			jump_count += 1
	else:
		if jump_count < max_jumps  and Input.is_action_just_pressed("jump"):
			jump_count += 1
			velocity.y = lerp(velocity.y, air_jump_scale * jump_force, delta * jump_lerp_speed)

	
	#ANIMATIONS
	if direction.length() == 0:
		state_machine.travel("Idle")
	elif not is_on_floor():
		state_machine.travel("Idle")
	else:
		state_machine.travel("Walk")
	pass

	#DEBUG OUTPUT
	var velocitynode=get_node("DebugUIContainer/vy/vely2")
	var maxvynode=get_node("DebugUIContainer/maxvy/maxvy2")
	var gravnode=get_node("DebugUIContainer/gravity/grav2")
	var hinode=get_node("DebugUIContainer/height/hi2")
	var maxhnode=get_node("DebugUIContainer/maxh/maxh2")
	var minhnode=get_node("DebugUIContainer/minh/minh2")
	var lasthnode=get_node("DebugUIContainer/lasth/lasth2")
	var jumpsnode=get_node("DebugUIContainer/jumps/jumps2")
	var flornode=get_node("DebugUIContainer/flor/flor2")
	var maxhcounter=float(maxhnode.text)
	var lasthcounter = float(lasthnode.text)
	var maxvycounter=float(maxvynode.text)
	var minhcounter=float(minhnode.text)
	
	jumpsnode.text=str(jump_count)
	gravnode.text=str(gravity)
	
	hinode.text=str(stepify(global_transform.origin.y,0.01)-1.95)
	flornode.text=str(is_on_floor())
	
	#Velocity-Y 
	velocitynode.text=str(stepify(velocity.y,0.01))
	#MaxVel-Y Counter
	if velocity.y>maxvycounter:
		maxvycounter=velocity.y
		maxvynode.text=str(stepify(maxvycounter,0.01))
	pass
	
	#Max Height Counter
	if global_transform.origin.y>maxhcounter:
		maxhcounter=global_transform.origin.y
		maxhnode.text=str(stepify(maxhcounter,0.01))
	pass
	#Min Height Counter
	if global_transform.origin.y<minhcounter:
		minhcounter=global_transform.origin.y
		minhnode.text=str(stepify(minhcounter,0.01))
	pass
	
	#Last Height Counter
	if lasthreset :
		if not is_on_floor() :
			lasthnode.text="0"
			lasthreset=false
	else:
		if not is_on_floor() : #if NOT time to reset and OFF the floor, start making a new lasth
			if global_transform.origin.y>lasthcounter:
				lasthcounter=global_transform.origin.y
				lasthnode.text=str(stepify(lasthcounter,0.01))
		else: #If NOT time to reset, and ON the floor, signal time to reset.
			lasthreset=true
	pass
	#maxhnode.text=str(maxhcounter)

func hurt(source,dmg):
	var oldhealth=health
	var totaldmg=0
	#allows for damage types
	for dmginstance in dmg:
		#take each instance of damage here
		var dmgval = dmg[dmginstance] #dmg["shadow"]=10 
		totaldmg += dmgval
		health -= dmgval
	lastHit = dmg
	emit_signal("hitSignal",oldhealth,health,totaldmg)
	if (health <= 0):
		killer = source
		timeToDie(health)
	pass

func timeToDie(health):
	emit_signal("deathsignal",health,lastHit)
	#print(lastHit,killer,health)
	pass
