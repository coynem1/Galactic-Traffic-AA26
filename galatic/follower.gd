extends Boid

'''
This represents the ship for either a leader or follower
'''

@onready var spaceship: Node3D = $spaceship
@onready var grabpoint: Node3D = $Grabpoint

var _is_dying: bool = false
var base_max_speed: float
var selected: bool = false
var leader: bool = false:
	set(value):
		leader = value
		grabpoint.enabled(value)

func _ready():
	super._ready()
	seekEnabled = true
	
	#if leader:
		#offsetPursueEnabled = true

# Set during runtime for defaults
func init():
	base_max_speed = max_speed
	distance = 1
	
	if leader:
		wanderTarget = Vector3.ZERO
	else:
		_setup_follower()
	
func _setup_follower():
	if leaderBoid != null:	# Already assigned
		return
	if offsetPursueEnabled and leaderNodePath:
		leaderBoid = get_node_or_null(leaderNodePath)

	if jitterWanderEnabled:
		wanderTarget = random_point_in_unit_sphere() * radius

func _physics_process(delta: float) -> void:
	if leader:
		_leader_movement()
		print("Target ", seekTarget)
	else:
		_followerMovement()
		
	super._physics_process(delta)

func _leader_movement():
	if selected:
		seekTarget = Util.get_mouse_world_position(global_position)
	else:
		seekTarget = global_position  # seek own position = no force applied

func _followerMovement():
	if leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	else:
		# Leader is dead so wander
		if not _is_dying:
			seekEnabled = false
			jitterWanderEnabled = true
	
func set_colour(colour: Color, full: bool):
	spaceship.set_colour(colour, full)

func _on_grabpoint_grabbing(value: bool) -> void:
	selected = value
	
	# Speed up when selected	
	if selected:
		max_speed = base_max_speed * 2
	else:
		max_speed = base_max_speed
