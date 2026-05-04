# dialog.gd
extends Control

@onready var dialog_label = $HBoxContainer/PanelContainer/VBoxContainer/DialogText
@onready var face = $Control/AnimatedSprite2D
@onready var name_label = $HBoxContainer/PanelContainer/VBoxContainer/Name

const DIALOG_TEMPLATES = {
	"formation_spawned": "A New Fleet Has Arrived From The %s!",
	"teleport":          "Good Job! You Successfully Transported The Fleet",
}

const DIALOG_CHARACTER = {
	"formation_spawned": "dylan",
	"teleport":          "ciaran",
}

var dialog_queue: Array = []
var is_showing: bool = false

func register_source(node):
	node.dialog_event.connect(receive_dialog)
	
func _ready():
	add_to_group("dialog")  
	visible = false
	await get_tree().process_frame
	_connect_sources()

func _connect_sources():
	for node in get_tree().get_nodes_in_group("dialog_sources"):
		node.dialog_event.connect(receive_dialog)

func receive_dialog(type: String, info: String = "", anim: String = ""):
	if not DIALOG_TEMPLATES.has(type):
		return
	var template = DIALOG_TEMPLATES[type]
	var message = template % info if "%s" in template else template
	var character = DIALOG_CHARACTER.get(type, "dylan")
	queue_dialog(message, character)

func queue_dialog(text: String, anim: String):
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
	name_label.text = entry["anim"].capitalize() 
	face.play(entry["anim"])

	await get_tree().create_timer(3.0).timeout
	_show_next()

	await get_tree().create_timer(3.0).timeout
	_show_next()
