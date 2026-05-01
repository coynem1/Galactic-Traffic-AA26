extends CharacterBody3D

@export var mass: float = 1.0
@export var force = Vector3.ZERO
@export var acceleration = Vector3.ZERO
@export var speed:float
@export var max_speed: float = 10.0

@export var seekEnabled = false
@export var seekTarget: Vector3

@export var targetNodePath:NodePath

var targetNode:Node

@export var arriveEnabled = false
@export var arriveTarget: Vector3
@export var slowingDistance = 35

@export var banking: float = 0.1

@export var pathFollowEnabled = false
var pathIndex = 0
var path:Path3D
var waypointSeekDistance = 2

@export var pursueEnabled = false
@export var enemyNodePath:NodePath
var enemyBoid:Node
var pursueTarget:Vector3

@export var offsetPursueEnabled = false
@export var leaderNodePath:NodePath
var leaderBoid:Node
var leaderOffset:Vector3

@export var controllerSteeringEnabled = false
@export var power: float = 30.0

@export var drawGizmos = false

@export var jitterWanderEnabled = false
@export var distance:float = 20
@export var radius:float  = 10
@export var jitter:float = 10
var wanderTarget:Vector3

@export var avoidanceEnabled = false
@export var feeler_angle: float = 45.0
@export var feeler_length: float = 10.0
enum ForceDirection {Normal, Incident, Up, Braking}
@export var avoidance_direction = ForceDirection.Normal
var avoidance_force = Vector3.ZERO
var needs_updating = true


func random_point_in_unit_sphere() -> Vector3:
	var v = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	return v.normalized() * randf()
	
func _find_leader():
	if offsetPursueEnabled:
		leaderBoid = get_node_or_null(leaderNodePath)
		print("leader: ", leaderBoid)
		print("leaderOffset will be: ", (transform.origin) * leaderBoid.transform.basis)
	if jitterWanderEnabled:
		wanderTarget = random_point_in_unit_sphere() * radius

func on_draw_gizmos():
	
	# DebugDraw.draw_line(transform.origin,  transform.origin + transform.basis.z * 10.0 , Color(0, 0, 1))
	#DebugDraw.draw_line(transform.origin,  transform.origin + transform.basis.x * 10.0 , Color(1, 0, 0))
	#DebugDraw.draw_line(transform.origin,  transform.origin + transform.basis.y * 10.0 , Color(0, 1, 0))
	DebugDraw3D.draw_line(transform.origin, transform.origin + (force * 20), Color(1, 1, 0))
	
	if pursueEnabled:
		DebugDraw3D.draw_sphere(pursueTarget, 1, Color.RED)
	
	if (arriveEnabled):
		DebugDraw3D.draw_sphere(targetNode.position, slowingDistance, Color.BLUE_VIOLET)

func jitterWander():
	var delta = get_process_delta_time()

	var disp = jitter * random_point_in_unit_sphere() * delta
	wanderTarget += disp
	wanderTarget.y = 0;
	wanderTarget = wanderTarget.limit_length(radius)
	# print("wanderTarget" + str(wanderTarget))
	var localTarget = (Vector3.FORWARD * distance) + wanderTarget;

	var worldTarget = global_transform * (localTarget)
	# print("world" + str(worldTarget))
	
	var cent = global_transform * (Vector3.FORWARD * distance)
	DebugDraw3D.draw_sphere(cent, radius, Color.DEEP_PINK)
	DebugDraw3D.draw_line(global_transform.origin, cent, Color.YELLOW_GREEN)
	DebugDraw3D.draw_line(cent, worldTarget, Color.BLUE_VIOLET)
	
	DebugDraw3D.draw_sphere(worldTarget, 1)
	var f = worldTarget - global_transform.origin;
	DebugDraw3D.draw_line(global_transform.origin, global_transform.origin + f)
	return f
	

func pursue():
	var toEnemy = enemyBoid.transform.origin - transform.origin	
	var dist = toEnemy.length()	
	var time = dist / max_speed	
	pursueTarget = enemyBoid.transform.origin + enemyBoid.velocity * time	
	return seek(pursueTarget)

# Called when the node enters the scene tree for the first time.
func _ready():	
	randomize()
	call_deferred("_find_leader")
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().get_size()
	10
	print("leaderBoid: ", leaderBoid)
	print("my position: ", global_position)
	print("offsetPursueEnabled: ", offsetPursueEnabled)
	# OS.set_window_position(screen_size*0.5 - window_size*0.5)

	if targetNodePath:	
		targetNode = get_node(targetNodePath)
	if pathFollowEnabled:
		path = $"../Path3D"
		
	if pursueEnabled:
		enemyBoid = get_node(enemyNodePath)
	pass	
	if offsetPursueEnabled:
		leaderBoid = get_node(leaderNodePath)
		leaderOffset = (transform.origin) * leaderBoid.transform.basis
	if jitterWanderEnabled:
		wanderTarget = random_point_in_unit_sphere() * radius	

func seek(target: Vector3):	
	var toTarget = target - transform.origin
	toTarget = toTarget.normalized()
	if toTarget.length() < 0.001:  
		return Vector3.ZERO
	var desired = toTarget * max_speed
	return desired - velocity

func controllerSteering():
	var projectedRight = transform.basis.x
	projectedRight.y = 0
	projectedRight = projectedRight.normalized()
	var turn = - Input.get_axis("turn_left", "turn_right")
	var move = - Input.get_axis("move_forward", "move_back")
	var force:Vector3
	force += move * transform.basis.z * power
	force += turn * projectedRight * power
	return force	
	
func arrive(target:Vector3):
	var toTarget = target - transform.origin
	var dist = toTarget.length()
	if dist < 0.001:  # ADD THIS GUARD
		return Vector3.ZERO
	var ramped = (dist / slowingDistance) * max_speed
	var limit_length = min(max_speed, ramped)
	var desired = (toTarget * limit_length) / dist 
	return desired - velocity

func followPath():
	var target = path.transform * (path.get_curve().get_point_position(pathIndex))
	var dist = global_transform.origin.distance_to(target)
	if dist < waypointSeekDistance:
		pathIndex = (pathIndex + 1) % path.get_curve().get_point_count()
	return seek(path.transform * (path.get_curve().get_point_position(pathIndex)))
	

func offsetPursue():
	if leaderBoid == null:
		return Vector3.ZERO
	var worldTarget = leaderBoid.global_transform.origin + leaderBoid.transform.basis * leaderOffset
	var dist = transform.origin.distance_to(worldTarget)
	if dist < 0.001:
		return Vector3.ZERO
	var time = dist / max_speed
	var projected = worldTarget + leaderBoid.velocity * time
	return arrive(projected)
	
func feel(local_ray) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var ray_end = global_transform * local_ray
	var query = PhysicsRayQueryParameters3D.create(global_transform.origin, ray_end, collision_mask)
	var result = space_state.intersect_ray(query)
	if result:
		var to_boid = global_transform.origin - result.position
		var force_mag = (feeler_length - to_boid.length()) / feeler_length
		match avoidance_direction:
			ForceDirection.Normal:
				return result.normal * force_mag
			ForceDirection.Incident:
				return to_boid.reflect(result.normal).normalized() * force_mag
			ForceDirection.Up:
				return Vector3.UP * force_mag
			ForceDirection.Braking:
				return to_boid.normalized() * force_mag
	return Vector3.ZERO

func obstacleAvoidance() -> Vector3:
	avoidance_force = Vector3.ZERO
	var forwards = Vector3.BACK * feeler_length
	avoidance_force += feel(forwards)
	avoidance_force += feel(Quaternion(Vector3.UP, deg_to_rad(feeler_angle)) * forwards)
	avoidance_force += feel(Quaternion(Vector3.UP, deg_to_rad(-feeler_angle)) * forwards)
	avoidance_force += feel(Quaternion(Vector3.RIGHT, deg_to_rad(feeler_angle)) * forwards)
	avoidance_force += feel(Quaternion(Vector3.RIGHT, deg_to_rad(-feeler_angle)) * forwards)
	return avoidance_force

func calculate():
	var f = Vector3.ZERO
	if seekEnabled:
		if targetNode:
			seekTarget = targetNode.transform.origin	
		f += seek(seekTarget)
	if arriveEnabled:
		arriveTarget = targetNode.transform.origin
		f += arrive(arriveTarget)
	if (pathFollowEnabled):
		f += followPath()
	if pursueEnabled:
		f += pursue()
	if offsetPursueEnabled and leaderBoid != null:
		f += offsetPursue()
	if controllerSteeringEnabled:
		f += controllerSteering()
	if jitterWanderEnabled:
		f += (jitterWander())
	if avoidanceEnabled:
		f += obstacleAvoidance()
	return f
	
func _physics_process(delta):			
	force = calculate()
	if mass == null or mass == 0:
		mass = 1
	acceleration = force / mass
	velocity += acceleration * delta
	speed = velocity.length()
	if speed > 0.1:
		velocity = velocity.limit_length(max_speed)
		# var tempUp = transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0) I comment this out to stop crash but might be needed for banking
		var look_target = global_position + velocity
		if look_target.distance_to(global_position) > 0.001:
			look_at(look_target, Vector3.UP)
	if drawGizmos:
		on_draw_gizmos()	
	move_and_slide()
	
		
