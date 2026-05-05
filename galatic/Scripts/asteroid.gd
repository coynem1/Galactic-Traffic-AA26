extends RigidBody3D

const DESTROY := "destroy"
const MAX_SCALE := 1.2
const MIN_SCALE := 0.8
signal destroy(value: Node)
signal blow_up(pos: Vector3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size: float = randf_range(MIN_SCALE, MAX_SCALE)
	scale = Vector3(size, size, size)
	
	body_entered.connect(_on_body_entered)
	destroy.connect(_on_body_entered)	

func _on_area_hit(body: Node) -> void:
	if body is Ship:
		if body.has_signal("destroy"):
			body.emit_signal("destroy", body)
			_destroy()

func _destroy():
	# Do something to the asteroid here. RN i delete it
	blow_up.emit(self.position)
	queue_free()

# When a collision happens 
func _on_body_entered(body: Node) -> void:
	_destroy()

func _on_visible_on_screen_destroy_object() -> void:
	_destroy()
