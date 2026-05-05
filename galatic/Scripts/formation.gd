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
signal blow_up(pos: Vector3)
signal dialog_event(type: String, info: String)

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
			# Blow up
			for child in get_children():
				blow_up.emit(child.global_position)
			destroy_all()

# Ship teleporting through wormhole 
func on_teleport_ship(ship: Ship) -> void:
	var duration: float = 0.6	# animation
	
	if ship == leader:
		add_points.emit(PointsUtil.LEADER_POINTS_VALUE + PointsUtil.FOLLOWER_POINTS_VALUE * followerCount)
		
		for child in get_children():
			if child is Ship:
				child.teleport_animation(duration)
		await get_tree().create_timer(duration).timeout
		
		emit_signal("dialog_event", "teleport", "")
		await get_tree().process_frame
		destroy_all()
	else:
		add_points.emit(PointsUtil.FOLLOWER_POINTS_VALUE)
		
		ship.teleport_animation(duration)
		await get_tree().create_timer(duration).timeout
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
	
	leader.connect("teleported", on_teleport_ship)
	leader.connect("destroy", _on_destroy)
	
	leader.set_colour(formation_colour, true)
	leader.init()


func spawn_followers() -> void:
	var offsets := get_offsets()
	var desaturated_colour = Color.from_hsv(formation_colour.h, formation_colour.h, 0.3)
	followerCount = offsets.size()
	
	for i in range(followerCount):
		var follower = follower_scene.instantiate()
		
		add_child(follower)
		
		# Rotate offset by leader's current orientation
		var rotated_offset = rotation_degrees * offsets[i]
		#print("formation rotation: ", rotation_degrees)
		
		follower.global_position = leader.global_position + rotated_offset
		#follower.global_position = global_position + offsets[i]
		follower.leaderBoid = leader
		follower.offsetPursueEnabled = false
		follower.seekEnabled = true
		follower.max_speed = max_speed * 1.5
		follower.slowingDistance = 0.1
		follower.leaderOffset = offsets[i]
		
		follower.set_colour(desaturated_colour, false)
		follower.connect("teleported", on_teleport_ship)
		follower.connect("destroy", _on_destroy)
	
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

# Blow up ship
func _on_destroy(ship: Node):
	# Blow up
	blow_up.emit(ship.global_position)
	
	if ship == leader:
		if not dying:
			start_dying()
	else:
		destroy_follower(ship)

			
func get_offsets() -> Array:
	var raw := []
	
	match formation_type:
		FormationType.DIAMOND:
			raw = [
				Vector3(-4,0,0),
				Vector3(4,0,0),
				Vector3(0,0,4),
				Vector3(0,0,-4),
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
			
	# Apply scale formation	
	return raw.map(func(v): return v * formation_scale)	
	
