extends KinematicBody
var health=10
#var types=[]
var speed = 2 # The movement speed of the player in units per second
var gravity = -65 # The gravity force applied to the player in units per second squared
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player
var target_velocity = Vector3.ZERO # A vector that stores the desired velocity of the player based on input
var acceleration = .5 #how fast to gain units/second
var turn_speed = 4
var sight_range = 35
var hit #line of sight check hit
var player = null

func _ready():
	$sight.connect("body_entered", self, "_on_sight_body_entered")
	$sight.connect("body_exited", self, "_on_sight_body_exited")
pass

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP,false,4,0.785398,false)
	
	if player != null:
		var raydir = (player.global_transform.origin - $sight/los.global_transform.origin).normalized()
		$sight/los.cast_to = raydir * sight_range
		hit = $sight/los.get_collision_point()
		
		if hit == Vector3.ZERO:
			var direction = (player.global_transform.origin - global_transform.origin).normalized()
			velocity = move_and_slide(direction * speed,Vector3.UP,false,40.785398,false)
			var target = player.global_transform.basis.get_rotation_quat()
			var current = global_transform.basis.get_rotation_quat()
			
			global_transform.basis = Basis(current.slerp(target, turn_speed * delta))
		else:
			velocity = Vector3.ZERO
			
	else:
		$sight/los.cast_to = Vector3(0,0,-35)
	#Debug UI
	var playertextnode=get_node("debugUI/playertext/playertext2")
	var bodygroups=get_node("debugUI/bodygroups/body2")
	var casttonode = get_node("debugUI/castto/castto2")
	var losnode = get_node("debugUI/sling-los/los2")
	var loscollidernode = get_node("debugUI/loscollider/loscollider2")
	
	losnode.text=str(hit)
	loscollidernode.text=str($sight/los.get_collider())
	casttonode.text = str($sight/los.cast_to)
	playertextnode.text=str(player)
	bodygroups.text=str(get_tree().get_nodes_in_group("my_group"))
pass



func _on_sight_body_entered(body):
	$debugUI/enterconnected/enterconnected2.text="true"
	var bodytextnode=get_node("debugUI/body/body2")
	bodytextnode.text=str(body)
	if body.is_in_group("player"):
		player = body

func _on_sight_body_exited(body):
	$debugUI/exitconnected2/exitconnected2.text="true"
	var bodytextnode=get_node("debugUI/body/body2")
	bodytextnode.text=str(body)
	if body == player:
		player = null
