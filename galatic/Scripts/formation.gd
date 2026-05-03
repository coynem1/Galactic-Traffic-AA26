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

var leader: Boid
var followerCount: int = 0
var formation_colour := Color.from_hsv(randf(), 1.0, 1.0)	# Random Hue
var dying: bool = false
var dying_timer: float = 0.0
@export var dying_timeout: float = 10.0  # tweak this based on your boundary size and speed

signal formation_destroyed
signal add_points(value: int)

# Initialises everything
func setup(type: FormationType, spawn_pos: Vector3) -> void:
	formation_type = type
	global_position = spawn_pos
	spawn_leader()
	spawn_followers()

# HACK: Handles dying		
func _process(delta: float) -> void:
	# Also start dying if leader was destroyed externally e.g by asteroid
	if not dying and (leader == null or not is_instance_valid(leader)):
		start_dying()
	if dying:
		dying_timer += delta
		var all_dead = true
		for child in get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion():
				all_dead = false
				break
		if all_dead or dying_timer >= dying_timeout:
			destroy_all()

# Ship teleporting through wormhole 
func on_teleport_ship(ship: Ship) -> void:
	if ship == leader:
		add_points.emit(PointsUtil.LEADER_POINTS_VALUE + PointsUtil.FOLLOWER_POINTS_VALUE * followerCount)
		destroy_all()
	else:
		add_points.emit(PointsUtil.FOLLOWER_POINTS_VALUE)
		destroy_follower(ship)

func destroy_all():
	formation_destroyed.emit()
	queue_free()
	
func destroy_follower(ship: Ship):
	followerCount -= 1
	ship.queue_free()
		
# Spawning at the start			
func spawn_leader() -> void:
	leader = leader_scene.instantiate()
	add_child(leader)
	
	leader.leader = true
	leader.global_position = global_position
	leader.max_speed = max_speed
	leader.distance = wander_distance  
	leader.radius = wander_radius      
	leader.jitter = wander_jitter
	
	var area = leader.get_node("Area3D")
	area.body_entered.connect(_on_leader_hit)
	leader.connect("teleported", on_teleport_ship)
	
	leader.set_colour(formation_colour, true)
	leader.init()

func spawn_followers() -> void:
	var offsets := get_offsets()
	var desaturated_colour = Color.from_hsv(formation_colour.h, formation_colour.h, 0.3)
	followerCount = offsets.size()
	
	for i in range(followerCount):
		var follower = follower_scene.instantiate()
		var area = follower.get_node("Area3D")
		
		add_child(follower)
		
		follower.global_position = global_position + offsets[i]
		follower.leaderBoid = leader
		follower.offsetPursueEnabled = false
		follower.seekEnabled = true
		follower.max_speed = max_speed
		
		follower.set_colour(desaturated_colour, false)
		follower.connect("teleported", on_teleport_ship)
		
		# Get the followers area 3d
		area.body_entered.connect(_on_follower_hit.bind(follower))
	
# Dying
func start_dying() -> void:
	if dying:
		return
	dying = true
	
	for child in get_children():
		if child is CharacterBody3D:
			child.seekEnabled = false
			child.jitterWanderEnabled = true
	if is_instance_valid(leader):
		leader.queue_free()
		leader = null

func _on_leader_hit(body: Node) -> void:
	if body is StaticBody3D and not dying:
		start_dying()
		
func _on_follower_hit(body: Node, follower: Boid) -> void:
	if body is StaticBody3D:
		if is_instance_valid(follower):
			destroy_follower(follower)
			
func get_offsets() -> Array:
	var raw := []
	var rotation_basis := Basis(Vector3.UP, leader.rotation.y)
	
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
			
	# Apply rotation and scale formation	
	return raw.map(func(v): return rotation_basis * (v * formation_scale))	
	
