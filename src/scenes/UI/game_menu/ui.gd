extends Control

signal continued
signal respawned
signal teleport(l)

# Declaración de variables @onready para cada nodo
@onready var got_item = $GotItem
@onready var npc_dialog = $NpcDialog
@onready var top_bar = $TopBar
@onready var room = $room
@onready var gamepad = $Gamepad
@onready var teleporter = $teleporter
@onready var cutscenes = $Cutscenes
@onready var map_menu = $MapMenu
@onready var pause_menu = $PauseMenu

# Creación del hash table (diccionario) con referencias a los nodos
var nodes_dict
func _ready():
	nodes_dict= {
	"GotItem": got_item,
	"NpcDialog": npc_dialog,
	"TopBar": top_bar,
	"Room": room,
	"Gamepad": gamepad,
	"Teleporter": teleporter,
	"Cutscenes": cutscenes,
	"MapMenu": map_menu,
	"Pause": pause_menu
}
var debug_items = [
	"Room",
	"Teleporter"
]
	
func show_game_ui():
	top_bar.show()
	gamepad.show()
	if PlayerData.debug:
		room.show()
		teleporter.show()
func continue_game():
	hide_all()
	show_game_ui()
	emit_signal("continued")
	get_tree().paused=false
func show_element(name):
	var n = nodes_dict.get(name, false)
	if not n: return
	pause()
	n.show()
func hide_all():
	for i in nodes_dict:
		var n = nodes_dict[i]
		nodes_dict[i].visible = false
func pause():
	get_tree().paused=true
	hide_all()
	
func respawn():
	emit_signal("respawned")


func _on_teleport(location: String) -> void:
	emit_signal("teleport", location)
