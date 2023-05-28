class_name enemyobj extends KinematicBody

enum state {idle,chase,find,attack,recover,tether}
var cur_state = state.idle

func _ready():
	pass

func process_states():
	var statenode=get_node("debugUI/statedbg/statedbg2")
	match cur_state:
		state.idle:
			statenode.text = str("idle")
			process_idle()
		state.chase:
			statenode.text = str("chase")
			process_chase()
		state.attack:
			statenode.text = str("attack")
			process_attack()
		state.find:
			statenode.text = str("find")
			process_find()
		state.recover:
			statenode.text = str("recover")
			process_recover()
		state.tether:
			statenode.text = str("tether")
			process_tether()

func enter_state(pass_state):
	if (cur_state != pass_state):
		leave_state(cur_state)
		cur_state=pass_state

func leave_state(pass_state):
	pass

func process_idle():
	pass
func process_chase():
	pass
func process_attack():
	pass
func process_find():
	pass
func process_recover():
	pass
func process_tether():
	pass
