# dialog.gd
extends Control

@onready var dialog_label = $HBoxContainer/PanelContainer/VBoxContainer/DialogText
@onready var face = $Control/AnimatedSprite2D

const DIALOG_TEMPLATES = {
	"formation_spawned": "A New Formation Has Arrived From The %s!",
	"teleport":          "The ship has teleported to the %s!",
}

var dialog_queue: Array = []
var is_showing: bool = false
var person = "dylan"

func _ready():
	visible = false
	# Wait a frame so all sibling nodes in GameScene are ready
	await get_tree().process_frame
	_connect_sources()

func _connect_sources():
	for node in get_tree().get_nodes_in_group("dialog_sources"):
		node.dialog_event.connect(receive_dialog)

func receive_dialog(type: String, info: String = "", anim: String = person):
	if not DIALOG_TEMPLATES.has(type):
		return
	var message = DIALOG_TEMPLATES[type] % info
	queue_dialog(message, anim)

func queue_dialog(text: String, anim: String = person):
	dialog_queue.append({"text": text, "anim": anim})
	if not is_showing:
		_show_next()

func _show_next():
	if dialog_queue.is_empty():
		visible = false
		is_showing = false
		return

	is_showing = true
	visible = true
	var entry = dialog_queue.pop_front()
	dialog_label.text = entry["text"]
	face.play(entry["anim"])

	await get_tree().create_timer(3.0).timeout
	_show_next()
