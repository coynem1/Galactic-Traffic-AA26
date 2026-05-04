extends Node3D

@onready var boom: AudioStreamPlayer3D = $Boom
@onready var burst: GPUParticles3D = $Burst

func explosion():
	burst.emitting = true
	boom.play()
	await get_tree().create_timer(3.0).timeout
	queue_free()
