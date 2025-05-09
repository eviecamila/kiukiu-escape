extends Node2D
class_name InvItem

signal grabbed
signal grab_started
signal finished
signal special_d


@onready var sprite : AnimatedSprite2D = $sprite
@onready var sfx : AudioStreamPlayer = $sfx
@export var texto = ""
@export var sfx_path = ""
var got_item: GotItem
var can_pick = true
var special = false

var bgm_path = "/root/Stage/BGM"
var bgm
func _ready() -> void:
	special = get_meta("special", false)
	sprite.animation = self.get_meta("item", "")
	sprite.play()
	if not bgm: bgm = get_node(bgm_path)
	# print(bgm)
	
	if special:
		var got_item_scene = preload("res://src/scenes/UI/got_item/GotItem.tscn")
		got_item = got_item_scene.instantiate()
		got_item.connect("ending", Callable(self, "_on_got_item_finished"))

func on_touched(body: Node2D) -> void:
	if can_pick and "Hen" in body.to_string():
		bgm.stream_paused = true
		if special: special_display(self)
		else: _pickup()

func _pickup():
	visible = false
	emit_signal("grabbed")
	if sfx_path: sfx.set_stream(load("res://assets/audio/%s"%[sfx_path]))
	sfx.seek(0)
	sfx.play()
	can_pick = false
	await sfx.finished 
	bgm.stream_paused = false
	emit_signal("finished")
	queue_free()
	


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
