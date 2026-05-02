extends "res://Scripts/boid.gd"
var _is_dying: bool = false

func _ready():
	super._ready()
	seekEnabled = true

func _physics_process(delta: float) -> void:
	if leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	else:
		# Leader is dead so wander
		if not _is_dying:
			seekEnabled = false
			jitterWanderEnabled = true
	super._physics_process(delta)
