extends Node3D

@export var formation_scene: PackedScene
@export var leader_scene: PackedScene
@export var follower_scene: PackedScene
@export var spawn_interval: float = 10.0
@export var max_formations: int = 3
@export var spawn_radius: float = 40.0

# Tweaks for all the formations
@export var max_speed: float = 2.0
@export var wander_distance: float = 4.0
@export var wander_radius: float = 2.0
@export var wander_jitter: float = 2.0
@export var formation_scale: float = 1.0

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		if get_child_count() < max_formations:
			spawn_formation()

func spawn_formation() -> void:
	var formation = formation_scene.instantiate()
	add_child(formation)
	
	formation.leader_scene = leader_scene
	formation.follower_scene = follower_scene
	formation.max_speed = max_speed
	formation.wander_distance = wander_distance
	formation.wander_radius = wander_radius
	formation.wander_jitter = wander_jitter
	formation.formation_scale = formation_scale
	
	# Picking a random formation type
	var type = randi() % 3
	# Picking a random spot to spawn
	var angle = randf_range(0, TAU)
	var spawn_pos = Vector3(
		cos(angle) * spawn_radius,
		0.0,
		sin(angle) * spawn_radius
	)
	formation.leader_scene = leader_scene
	formation.follower_scene = follower_scene
	formation.setup(type, spawn_pos)
	
			
