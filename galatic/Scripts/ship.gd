extends "res://Scripts/boid.gd"
var _is_dying: bool = false
var is_grabbed: bool = false

func _ready():
	super._ready()
	seekEnabled = true

func _physics_process(delta: float) -> void:
	if is_grabbed:
		seekTarget = _get_mouse_world_pos()
	elif leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderOffset
	else:
		# Leader is dead so wander
		if not _is_dying:
			seekEnabled = false
			jitterWanderEnabled = true
	super._physics_process(delta)

func _get_mouse_world_pos() -> Vector3:
	return Util.get_mouse_world_position(global_position)
