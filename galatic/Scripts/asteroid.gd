extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Detect Ships 
	var area = get_node("Area3D")
	area.body_entered.connect(_on_area_hit)

func _on_area_hit(body: Node) -> void:
	if body is CharacterBody3D:
		body.queue_free()
		# Do something to the asteroid here. RN i delete it
		queue_free()

# When a collision happens 
func _on_body_entered(body: Node) -> void:
	queue_free()
