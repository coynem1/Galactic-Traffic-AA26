class_name Ship
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

# Set during runtime to get default variables
func init():
	base_max_speed = max_speed
	
	if leader:
		pass
		#wanderTarget = Vector3.ZERO
	else:
		_setup_follower()
	
func _setup_follower():
	if leaderBoid != null:	# Already assigned
		return
	if offsetPursueEnabled and leaderNodePath:
		leaderBoid = get_node_or_null(leaderNodePath)

	if jitterWanderEnabled:
		wanderTarget = random_point_in_unit_sphere() * radius

# Movement
func _physics_process(delta: float) -> void:
	if leader:
		_leader_movement()
	else:
		_followerMovement()
		
	super._physics_process(delta)

func _leader_movement():
	if selected:
		jitterWanderEnabled = false
		seekEnabled = true
		seekTarget = Util.get_mouse_world_position(global_position)
		# Debug
		DebugDraw3D.draw_sphere(seekTarget, 0.5, Color.GREEN)
		DebugDraw3D.draw_sphere(global_position, 0.3, Color.RED)
		DebugDraw3D.draw_line(global_position, seekTarget, Color.YELLOW)
		DebugDraw3D.draw_line(global_position, global_position + velocity * 2, Color.BLUE)
		DebugDraw3D.draw_line(global_position, global_position + force * 2, Color.ORANGE)
	else:
		seekEnabled = false
		jitterWanderEnabled = true
		seekTarget = global_position

func _followerMovement():
	if leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	else:
		# Leader is dead so wander
		if not _is_dying:
			seekEnabled = false
			jitterWanderEnabled = true

# Setters
func set_colour(colour: Color, full: bool):
	spaceship.set_colour(colour, full)

# Signals
func _on_grabpoint_grabbing(value: bool) -> void:
	if not leader:
		return
	selected = value
	# Speed up when selected	
	if selected:
		max_speed = base_max_speed * 2
	else:
		max_speed = base_max_speed

	
	
