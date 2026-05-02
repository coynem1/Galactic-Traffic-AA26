extends "res://Scripts/boid.gd"

@onready var spaceship: Node3D = $spaceship

var leader: bool = false

func _ready():
	super._ready()
	offsetPursueEnabled = true

func set_colour(colour: Color, full: bool):
	spaceship.set_colour(colour, full)

#func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	### Match leader's rotation
	##if leaderBoid != null:
		##rotation = leaderBoid.rotation
