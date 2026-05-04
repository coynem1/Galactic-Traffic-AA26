extends Node3D

@export var formation_scene: PackedScene
@export var leader_scene: PackedScene
@export var follower_scene: PackedScene
@export var explosion_scene: PackedScene
@export var spawn_interval: float = 10.0
@export var max_formations: int = 3
@export var spawn_radius: float = 40.0

# Tweaks for all the formations
@export var max_speed: float = 2.0
@export var wander_distance: float = 4.0
@export var wander_radius: float = 2.0
@export var wander_jitter: float = 2.0
@export var formation_scale: float = 1.0

signal add_points(value: int)

var timer: float = 0.0
var active_formations: int = 0

# Spawns ships in intervals
func _process(delta: float) -> void:
	timer += delta
	if timer < spawn_interval:
		return
	timer = 0.0
	
	if get_child_count() < max_formations:
		spawn_formation()

func spawn_formation() -> void:
	var formation = formation_scene.instantiate()
	add_child(formation)
	active_formations += 1
	formation.formation_destroyed.connect(_on_formation_destroyed)
	formation.connect("add_points", _on_formation_add_points)
	formation.connect("blow_up", _on_blow_up_ship)
	
	formation.leader_scene = leader_scene
	formation.follower_scene = follower_scene
	formation.max_speed = max_speed
	formation.wander_distance = wander_distance
	formation.wander_radius = wander_radius
	formation.wander_jitter = wander_jitter
	formation.formation_scale = formation_scale
	
	var type = randi() % 3
	var angle = randf_range(0, TAU)
	var spawn_pos = Vector3(
		sin(angle) * -spawn_radius,
		0.0,
		cos(angle) * -spawn_radius
	)
	formation.rotation.y = angle + PI
	formation.setup(type, spawn_pos)
	
func _on_blow_up_ship(pos: Vector3) -> void:
	var boom := explosion_scene.instantiate()
	add_child(boom)
	boom.position = pos
	boom.explosion()
	
func _on_formation_destroyed() -> void:
	active_formations -= 1
	
func _on_formation_add_points(value: int):
	add_points.emit(value)
