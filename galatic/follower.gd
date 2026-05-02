extends "res://Scripts/boid.gd"

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
	
	if leader:
		offsetPursueEnabled = true

# Set during runtime for defaults
func init():
	base_max_speed = max_speed

func _physics_process(delta: float) -> void:
	if leader:
		_leader_movement()
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
	
	if selected:
		max_speed = base_max_speed * 2
	else:
		max_speed = base_max_speed
