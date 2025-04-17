extends Control
class_name GotItem

signal ending

@onready var label: Label = $Panel/Label
@onready var icon: Sprite2D = $Panel/Sprite2D
@onready var anim: AnimationPlayer = $Panel/AnimationPlayer
@onready var typesfx = $sfx

var text = "You got: "
var typing_speed = .05
var end = false

func _ready():
	visible = false
	self.size = Vector2(1280, 720)

func _input(event):
	
	if end:
		#print("termino el dialogo")
		if event.is_action_pressed("btn_1"): # Cambiado a is_just_pressed
			print('ok')
			_hide_item()

func show_item(item: InvItem) -> void:
	end = false
	get_tree().paused=true 
	icon.texture = item.sprite.sprite_frames.get_frame_texture(item.sprite.animation, 0)
	label.text = ""
	visible = true
	
	var full_text: String = item.texto if item.texto else text + item.get_meta("item", "???")
	
	var displayed_text: String = ""

	for i in full_text.length():
		displayed_text += full_text[i]
		label.text = displayed_text
		if full_text[i] != " ":  # opcional: no sonar en espacios
			typesfx.play()
		await get_tree().create_timer(typing_speed).timeout

	end = true # Marcar que el typing ha terminado y se puede presionar btn_1
	print("Typing terminado. Presiona btn_1 para continuar.")
	# No necesitamos un bucle aquí, _input se encargará de detectar la presión

func _hide_item():
	
	print('se acabo el gotitas')
	get_tree().paused=false
	end = false
	visible = false
	emit_signal("ending")
