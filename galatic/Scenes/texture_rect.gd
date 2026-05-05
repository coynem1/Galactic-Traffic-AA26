extends TextureRect

@export var pan_speed: float = 30.0  # pixels per second

var start_x: float = 0.0
var image_width: float = 0.0

func _ready():
	start_x = position.x
	image_width = size.x / 2.0  # assumes image is at least 2x screen width

func _process(delta: float) -> void:
	position.x -= pan_speed * delta
	if position.x <= start_x - image_width:
		position.x = start_x  # reset back to start seamlessly
