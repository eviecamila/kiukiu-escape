extends Node2D
class_name InvItem

signal grabbed

@onready var sprite : AnimatedSprite2D = $sprite
@onready var sfx : AudioStreamPlayer = $sfx

var got_item: GotItem

var special = false

func _ready() -> void:
	special = get_meta("special", false)
	sprite.animation = self.get_meta("item", "")
	sprite.play()
	if special:
		var got_item_scene = preload("res://src/scenes/UI/got item/got item.tscn")
		got_item = got_item_scene.instantiate()
		got_item.connect("ending", Callable(_on_got_item_finished))

func on_touched(body: Node2D) -> void:
	if "Hen" in body.to_string():
		if special:
			special_display(self)
		else:
			_pickup()

func _pickup():
	visible = false
	emit_signal("grabbed")
	sfx.play()
	await sfx.finished
	queue_free()

func special_display(item: InvItem):
	if is_instance_valid(get_node("/root/Stage")):
		get_node("/root/Stage/C").add_child(got_item)
	else:
		printerr("Error: No se encontró el nodo '/root/Stage'.")
		return # Importante salir si el nodo no existe

	if is_instance_valid(get_node("/root/Stage/C/SVPC/SVP")):
		print("Estado de pausa de /root/Stage/C/SVPC/SVP:", get_node("/root/Stage/C/SVPC/SVP").get_tree().paused)
	else:
		printerr("Advertencia: No se encontró el nodo '/root/Stage/C/SVPC/SVP' para imprimir su estado de pausa.")

	if is_instance_valid(get_node("/root/Stage/C")):
		get_node("/root/Stage/C/SVPC/SVP").get_tree().paused = true
	else:
		printerr("Error: No se encontró el nodo '/root/Stage/C'.")
		return # Importante salir si el nodo no existe

	if is_instance_valid(got_item):
		got_item.show_item(self)
	else:
		printerr("Error: got_item no está instanciado.")
func _on_got_item_finished():
	_pickup()


func _on_grabbed(item: Variant) -> void:
	pass # Replace with function body.
