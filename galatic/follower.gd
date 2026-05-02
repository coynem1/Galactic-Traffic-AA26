extends "res://Scripts/boid.gd"

@onready var spaceship: Node3D = $spaceship

var _is_dying: bool = false
var leader: bool = false

func _ready():
	super._ready()
	seekEnabled = true
	
	if leader:
		offsetPursueEnabled = true

func _physics_process(delta: float) -> void:
	if not leader:
		_followerMovement()
	
	super._physics_process(delta)

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
