extends Node3D

enum FormationType {DIAMOND, LINE, V_SHAPE}

@export var formation_type: FormationType = FormationType.V_SHAPE
@export var leader_scene: PackedScene
@export var follower_scene: PackedScene
@export var ship_count: int = 5

# Tweaks for all the formations
@export var max_speed: float = 2.0
@export var wander_distance: float = 6.0
@export var wander_radius: float = 0.5
@export var wander_jitter: float = 0.4
@export var formation_scale: float = 0.2

var leader: CharacterBody3D

func setup(type: FormationType, spawn_pos: Vector3) -> void:
		formation_type = type
		global_position = spawn_pos
		spawn_leader()
		spawn_followers()
		
func spawn_leader() -> void:
	leader = leader_scene.instantiate()
	add_child(leader)
	leader.global_position = global_position
	leader.jitterWanderEnabled = true
	leader.seekEnabled = false
	leader.max_speed = max_speed
	leader.distance = wander_distance  
	leader.radius = wander_radius      
	leader.jitter = wander_jitter
	var area = leader.get_node("Area3D")
	area.body_entered.connect(_on_leader_hit)
	
func _on_leader_hit(body: Node) -> void:
	if body is StaticBody3D:
		queue_free()
		
func spawn_followers() -> void:
	var offsets = get_offsets()
	for i in range(offsets.size()):
		var follower = follower_scene.instantiate()
		add_child(follower)
		follower.global_position = global_position + offsets[i]
		follower.leaderBoid = leader
		follower.offsetPursueEnabled = false
		follower.seekEnabled = true
		follower.max_speed = max_speed

func get_offsets() -> Array:
	var raw = []
	match formation_type:
		FormationType.DIAMOND:
			raw = [
				Vector3(-3,0,0),
				Vector3(3,0,0),
				Vector3(0,0,3),
				Vector3(0,0,-3),
			]
		FormationType.LINE:
			raw = [
				Vector3(0,0,3),
				Vector3(0,0,6),
				Vector3(0,0,9),
				Vector3(0,0,12),
			]
		FormationType.V_SHAPE:
			raw = [
				Vector3(-3,0,3),
				Vector3(3,0,3),
				Vector3(-6,0,6),
				Vector3(6,0,6),
			]
	return raw.map(func(v): return v * formation_scale)
		
