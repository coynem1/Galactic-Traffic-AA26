class_name Ship
extends Boid

'''
This represents the ship for either a leader or follower
'''

const BIG_NUMBER: float = 500

signal teleported(value: Ship)
signal destroy(value: Node)

@onready var spaceship: Node3D = $spaceship
@onready var grabpoint: Node3D = $Grabpoint
@onready var hitbox: Area3D = $Hitbox
@onready var teleport_sound: AudioStreamPlayer3D = $teleportSound

var _is_dying: bool = false
var invincible: bool = false
var base_max_speed: float
var selected: bool = false
var leader: bool = false:
	set(value):
		leader = value
		grabpoint.enabled(value)
var is_grabbed: bool = false
var touched: bool = false
var teleport_animating: bool = false

func _ready():
	super._ready()
	seekEnabled = true

# Set during runtime to get default variables
func init():
	base_max_speed = max_speed
	
	if leader:
		seekTarget = global_transform.origin + (-global_transform.basis.z * BIG_NUMBER)
	else:
		_setup_follower()
	
func _setup_follower():
	if leaderBoid != null:	# Already assigned
		return
	if offsetPursueEnabled and leaderNodePath:
		leaderBoid = get_node_or_null(leaderNodePath)

	if jitterWanderEnabled:
		wanderTarget = random_point_in_unit_sphere() * radius

# Movement
func _physics_process(delta: float) -> void:
	if leader:
		_leader_movement()
	else:
		_follower_movement()
		
	super._physics_process(delta)

func _leader_movement() -> void:
	if selected:
		seekTarget = MouseUtil.get_mouse_world_position(global_position)
		return
	
	if touched:
		seekTarget = global_position  # seek own position = no force applied

func _follower_movement() -> void:
	if leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	if is_grabbed:
		seekTarget = MouseUtil.get_mouse_world_position(global_position)
	elif leaderBoid != null and is_instance_valid(leaderBoid):
		seekTarget = leaderBoid.global_transform.origin + leaderOffset
	else:
		# Leader is dead so wander
		if not _is_dying:
			seekEnabled = false
			jitterWanderEnabled = true

# Setters
func set_colour(colour: Color, full: bool) -> void:
	spaceship.set_colour(colour, full)


func teleport_ship():
	teleported.emit(self)

func teleport_animation(duration: float):
	if teleport_animating:
		return false
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	
	invincible = true
	spaceship.use_secondary_shader(true)
	hitbox.monitoring = false
	hitbox.monitorable = false
	teleport_sound.play()
	
	tween.tween_property(self, "scale", Vector3.ZERO, duration)
	

# Signals
func _on_grabpoint_grabbing(value: bool) -> void:
	if not leader:
		return
	selected = value
	
	# First time
	if not touched:
		touched = value
	
	# Speed up when selected	
	if selected:
		max_speed = base_max_speed * 1.5
	else:
		max_speed = base_max_speed

# Signal on impact
func _on_area_3d_body_entered(body: Node) -> void:
	if body is StaticBody3D and not invincible:
		destroy.emit(self)

func _on_visible_on_screen_destroy_object() -> void:
	if not invincible:
		destroy.emit(self)

# Just appeared on screen
func _on_visible_on_screen_spawn_invinciblity(value: bool) -> void:
	invincible = value
