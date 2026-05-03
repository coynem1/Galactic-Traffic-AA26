extends RigidBody3D

const DESTROY := "destroy"
signal destroy(value: Node)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	destroy.connect(_on_body_entered)	

func _on_area_hit(body: Node) -> void:
	if body is Ship:
		if body.has_signal("destroy"):
			body.emit_signal("destroy", body)
			_destroy()

func _destroy():
	# Do something to the asteroid here. RN i delete it
	queue_free()

# When a collision happens 
func _on_body_entered(body: Node) -> void:
	_destroy()

func _on_visible_on_screen_destroy_object() -> void:
	_destroy()
