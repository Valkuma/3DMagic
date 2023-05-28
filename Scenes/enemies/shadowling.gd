extends enemyobj
var health=10
#enum state {idle,chase,find,attack,recover,tether}
#var types=[]
var speed = 4 # The movement speed of the player in units per second
var gravity = -65 # The gravity force applied to the player in units per second squared
var velocity = Vector3.ZERO # A vector that stores the current velocity of the player
var target_velocity = Vector3.ZERO # A vector that stores the desired velocity of the player based on input
var acceleration = .5 #how fast to gain units/second
var turn_speed = .10
var hit #line of sight check hit
var hitcollider #the collider of sight raycast
var colliderdistance #distance between object and collided object
var distnode #distance from collider to raycast debug
#var sling_state = state.idle #default state
var tetherpos = Vector3.ZERO

onready var raycast= $sight/los
onready var player = get_tree().get_root().get_node("level").get_node("PlayerScene").get_node("Player")

func _ready():
	distnode = get_node("debugUI/dist/dist2")



func _physics_process(delta):
	velocity.y += gravity * delta
	process_states()
	#DEBUGS
	
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

func _on_visionTimer_timeout():
	#if in tether or idle states, allow transition to chase based on sight.
	if (cur_state == state.tether or cur_state == state.idle):
		if self.check_sight(): #if i can see the player, chase.
			self.enter_state(state.chase)
#
#func process_states():
#	var statenode=get_node("debugUI/statedbg/statedbg2")
#	match sling_state:
#		state.idle:
#			statenode.text = str("idle")
#			process_idle()
#		state.chase:
#			statenode.text = str("chase")
#			process_chase()
#		state.attack:
#			statenode.text = str("attack")
#			process_attack()
#		state.find:
#			statenode.text = str("find")
#			process_find()
#		state.recover:
#			statenode.text = str("recover")
#			process_recover()
#		state.tether:
#			statenode.text = str("tether")
#			process_tether()
#	pass
	
# warning-ignore:unused_argument


func process_idle():
	var delta = get_physics_process_delta_time()
	velocity.x=0 #dont move
	velocity.z=0
	velocity.y += gravity * delta #gravity
	velocity=move_and_slide(velocity,Vector3.UP) #go nowhere but allow gravity.
	pass
	
func process_attack():
	if ($attackTimer.get_time_left() > 0):
		pass
	else:
		#Fire the attack event and hurt everything in the area
		var inDamage = $Attack/AttackHurtArea/.get_overlapping_bodies()
		if inDamage.size() > 0:
			for body in inDamage:
				var dmgVal = { "Shadow":10}
				body.hurt("Shadowling Bite",dmgVal)
				pass
		
		$recoveryTimer.start()
		self.enter_state(state.recover)
	pass
	
func process_recover():
	if ($recoveryTimer.get_time_left() > 0):
		pass
	else:
		#Transition to chase
		self.enter_state(state.chase)
	pass

func process_find():
	#check sight
	if check_sight():
		self.enter_state(state.chase)
	else:
		#visit the last known position and then do a twirl
		#tether if you fail to find the player
		self.enter_state(state.tether)
		pass
	pass

func process_tether():
	self.enter_state(state.idle)

	
func process_chase():
	var delta = get_physics_process_delta_time()
	var global_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	#smooth turning math
	var wtransform = global_transform.looking_at(Vector3(player_pos.x,global_pos.y,player_pos.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), turn_speed) 
	global_transform = Transform(Basis(wrotation), global_transform.origin) #turn towards player
	var player_direction = (player_pos - global_pos).normalized() #
	
	#if in sight, chase, otherwise transition to find.
	if check_sight():
		velocity = (speed*player_direction.normalized())
		velocity.y += gravity * delta #gravity
		velocity= move_and_slide(velocity,Vector3.UP,false,4,0.785398,false) #chase the player
	else:
		#transition to find the player
		self.enter_state(state.find)
	#detect if should transition to attacks
	var inAttack = $Attack/attackDetectArea.get_overlapping_bodies()
	if inAttack.size() > 0:
		for body in inAttack:
			if body.name == "Player":
				#Transition to attack - start the timer and fire the animation
				$attackTimer.start()
				$Attack/AttackHurtArea/Particles.restart()
				#animation-attack-fire
				self.enter_state(state.attack)
pass

func check_sight():
	var inSight = $sight.get_overlapping_bodies()
	if inSight.size() > 0:
		for body in inSight:
			if body.name == "Player":
				var playerPos = body.global_transform.origin
				$sight/los.look_at(playerPos, Vector3.UP)
				$sight/los.force_raycast_update()
				if $sight/los.is_colliding():
					var colbody = $sight/los.get_collider()
					if colbody.name == "Player":
						$sight/los.debug_shape_custom_color = Color(174,0,0)
						return true
					else:
						$sight/los.debug_shape_custom_color = Color(0,174,0)
						return false
	else:
		return false
	return false





#func _on_visionTimer_timeout():
#	var inSight = $sight.get_overlapping_bodies()
#	var losthim=true
#	if inSight.size() > 0:
#		for body in inSight:
#			if body.name == "Player":
#				var playerPos = body.global_transform.origin
#				losthim=false
#				$sight/los.look_at(playerPos, Vector3.UP)
#				$sight/los.force_raycast_update()
#				if $sight/los.is_colliding():
#					var colbody = $sight/los.get_collider()
#					if colbody.name == "Player":
#						$sight/los.debug_shape_custom_color = Color(174,0,0)
#						self.enter_state(state.chase)
#						print("player collide")
#					else:
#						$sight/los.debug_shape_custom_color = Color(0,174,0)
#						self.enter_state(state.idle)
#						print ("else collide")
#			if losthim:
#				self.enter_state(state.idle)
#	else:
#		self.enter_state(state.idle)
#pass 


func _on_attackTimer_timeout():
	pass # Replace with function body.
func _on_recoveryTimer_timeout():
	pass # Replace with function body.
