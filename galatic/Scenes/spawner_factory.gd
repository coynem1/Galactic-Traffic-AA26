extends Node3D

@export var boid_scene: PackedScene
@export var spawn_interval: float = 10.0
@export var max_boids: int = 10

var timer: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_boid()

func spawn_boid() -> void:
	if get_child_count() >= max_boids:
		return
	var boid = boid_scene.instantiate()
	add_child(boid)
	boid.global_position = global_position
	boid.jitterWanderEnabled = true
	boid.seekEnabled = false
	boid.offsetPursueEnabled = false
