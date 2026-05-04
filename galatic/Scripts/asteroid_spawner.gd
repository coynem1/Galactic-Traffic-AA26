extends Node

@export var asteroid_scene: PackedScene
@export var asteroid_explosion_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var asteroid_speed: float = 15.0
@export var spawn_radius: float = 20.0
@export var destroy_radius: float = 40.0

var timer: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_asteroid()

func spawn_asteroid() -> void:
	var asteroid = asteroid_scene.instantiate()
	add_child(asteroid)
	asteroid.connect("blow_up", _on_asteroid_blow_up)
	
	# Pick a rand point on circle perimeter
	var angle = randf_range(0, TAU)
	var spawn_pos = Vector3(
		cos(angle) * spawn_radius,
		0.0,
		sin(angle) * spawn_radius
	)
	
	asteroid.global_position = spawn_pos
	
	# Fire it toward the center with a bit of offset
	var target = Vector3(
		randf_range(-5.0, 5.0),
		0.0,
		randf_range(-5.0, 5.0),
	)
	var direction = (target - spawn_pos).normalized()
	asteroid.linear_velocity = direction * asteroid_speed

func _on_asteroid_blow_up(pos: Vector3) -> void:
	var boom := asteroid_explosion_scene.instantiate()
	add_child(boom)
	boom.position = pos
	boom.explosion()
	
	
func _physics_process(delta: float) -> void:
	# Check all the asteroids and destroy the ones too far away
	for asteroid in get_children():
		if asteroid.global_position.length() > destroy_radius:
			asteroid.queue_free()
	
