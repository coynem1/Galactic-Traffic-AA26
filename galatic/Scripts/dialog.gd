# dialog.gd
extends Control

@onready var dialog_label = $HBoxContainer/PanelContainer/VBoxContainer/DialogText
@onready var face = $Control/AnimatedSprite2D
@onready var name_label = $HBoxContainer/PanelContainer/VBoxContainer/Name
@onready var blip = $AudioStreamPlayer
@onready var alert = $AlertPlayer

const DIALOG_TEMPLATES = {
	"formation_spawned": "A New Fleet Has Arrived From The %s!",
	"teleport":          "Good Job! You Successfully Transported The Fleet",
}

const DIALOG_CHARACTER = {
	"formation_spawned": "dylan",
	"teleport":          "ciaran",
}

const DIALOG_PITCH = {
	"dylan":  1.0,
	"ciaran": 1.4, 
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
	
	# Clear dialog box to not show prev dialog
	dialog_label.visible_characters = 0
	dialog_label.text = ""
	name_label.text = ""
	
	name_label.text = entry["anim"].capitalize() 
	face.play(entry["anim"])
	
	alert.play()	# Radio Alert
	await get_tree().create_timer(alert.stream.get_length()).timeout  # waits for the alert to finish
	
	await _typewrite(entry["text"], entry["anim"])
	await get_tree().create_timer(2.0).timeout
	_show_next()
	
func _typewrite(text: String, character: String):
	dialog_label.text = text
	dialog_label.visible_characters = 0
	var char_pitch = DIALOG_PITCH.get(character, 1.0)
	for i in text.length():
		dialog_label.visible_characters += 1
		if text[i] != " ":  # skip spaces
			blip.pitch_scale = char_pitch + randf_range(-0.2, 0.2)  # slight pitch variation  randf_range(0.8, 1.2)
			blip.play()
		await get_tree().create_timer(0.05).timeout
		
