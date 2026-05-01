extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

# When a collision happens 
func _on_body_entered(body: Node) -> void:
	queue_free()
