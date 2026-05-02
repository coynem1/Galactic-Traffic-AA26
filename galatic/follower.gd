extends "res://Scripts/boid.gd"


func _ready():
	super._ready()
	offsetPursueEnabled = true

#func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	### Match leader's rotation
	##if leaderBoid != null:
		##rotation = leaderBoid.rotation
