extends VisibleOnScreenNotifier3D

'''
Responsible for detecting if an object has left the screen to delete
'''

signal destroy_object

var invincible: bool = false 
var on_screen: bool = false
var appeared_on_screen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cannot die before appearing on screen
	if not on_screen:
		invincible = true

func _on_screen_entered() -> void:
	on_screen = true
	
	if invincible:
		invincible = false
		appeared_on_screen = true

func _on_screen_exited() -> void:
	on_screen = false
	
	if appeared_on_screen:
		destroy_object.emit()
