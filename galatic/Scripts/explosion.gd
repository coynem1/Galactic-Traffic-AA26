extends Node3D

@onready var explode: GPUParticles3D = $Explode
@onready var boom: AudioStreamPlayer3D = $Boom

func explosion():
	explode.emitting = true
	boom.play()
	await get_tree().create_timer(3.0).timeout
	queue_free()
