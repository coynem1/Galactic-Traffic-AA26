extends "res://Scripts/boid.gd"


func _ready():
	super._ready()
	seekEnabled = true

func _physics_process(delta: float) -> void:
	if leaderBoid != null:
		seekTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	super._physics_process(delta)
