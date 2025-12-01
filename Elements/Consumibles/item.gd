extends Node2D
class_name InvItem

signal grabbed
signal grab_started
signal finished
signal special_d

@onready var sprite: AnimatedSprite2D = $sprite
@onready var sfx: AudioStreamPlayer = $sfx

@export var texto = ""
@export var sfx_path = null
@export var tool = false

var got_item: GotItem
var can_pick = true
var special = false
var to_inv = false
var nombre = "Objeto"
var _frame = 23
const frames = {
	"boots":0,
	"egg":1,
	"live":2,
	"gold_live":3,
	"pick":4,
	"block":5,
	"corn":6,
	"corn_plus":7,
	"cat_eye":8,
	"water": 9,
	"secret_egg":10,
}

var bgm_path = "/root/Stage/BGM"
var bgm

func _ready() -> void:
	special = get_meta("special", false)
	sprite.animation = self.get_meta("item", "")
	sprite.play()
	if not bgm:
		bgm = get_node(bgm_path)

	if special:
		var got_item_scene = preload("res://src/scenes/UI/got_item/GotItem.tscn")
		got_item = got_item_scene.instantiate()
		got_item.connect("ending", Callable(self, "_on_got_item_finished"))

func on_touched(body: Node2D) -> void:
	if can_pick and "Hen" in body.to_string():
		bgm.stream_paused = true
		if special:
			special_display(self)
		else:
			_pickup()

func _pickup():
	visible = false
	emit_signal("grabbed")
	add_to_inv()
	if sfx_path:
		sfx.set_stream(load("res://assets/audio/%s" % [sfx_path]))
	sfx.play()
	
	can_pick = false
	await sfx.finished
	
	bgm.stream_paused = false
	emit_signal("finished")

func add_to_inv():
	print(int(false))

	if not to_inv:
		return
		
	var anim = sprite.animation
	var path = get_parent()._path
	# Crear una nueva instancia de ItemData
	var item_data = ItemData.new(path, nombre, tool, frames[anim] if anim in frames else 23)

	# Agregar el ítem al inventario
	var inv = Inventory.get_instance()
	var add = inv.add_to_inv(item_data, !tool)
		


	
func special_display(item: InvItem):
	if is_instance_valid(get_node("/root/Stage/C")):
		get_node("/root/Stage/C").add_child(got_item)
	else:
		printerr("Error: No se encontró el nodo '/root/Stage/C'.")
		return

	GameStateManager.set_state(GameStateManager.State.DIALOG)

	if is_instance_valid(got_item):
		got_item.show_item(self)
	else:
		printerr("Error: got_item no está instanciado.")

func _on_got_item_finished():
	GameStateManager.set_state(GameStateManager.State.PLAYING)
	_pickup()
