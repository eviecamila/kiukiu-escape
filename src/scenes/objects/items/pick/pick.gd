extends Node2D
class_name SuperPico
signal grabbed
@onready var item = $Objeto # Asegúrate de que este nodo exista y sea un Label o similar
var _path = "res://src/scenes/objects/items/pick/pick.tscn"
func _ready() -> void:
	item.texto = "Acabas de obtener el Super Pico\nAhora puedes picar el suelo."
	item.nombre = "Super Pico"
	item.tool = true
	item.to_inv = true
func on_grabbed() -> void:
	print("¡Ahora tengo el Super Pico!")
	PlayerData.puede_atacar_con_pico = true
	print("Puedo usar el pico para atacar.")
func on_finished():
	queue_free() # O alguna forma de desaparecer el item
	
	
func use(hen:Hen):
	if !PlayerData.puede_atacar_con_pico: return
	PlayerData.puede_atacar_con_pico = false
	hen.attack_ended = false
	Meta._play_sound(hen.audio, "items/pick_hit.wav")
	atacar(hen.position, hen.sprite.flip_h)
	hen.sprite.play("attack")
	var direction = hen.get_direction()
	var prev_gravity = hen.gravity
	
	hen.gravity = 0
	
	# Mover	la gallina a cierto lugar
	for i in range(100):
		await hen.get_tree().create_timer(.001).timeout
		
		hen.position.x +=direction.x
		hen.position.y +=direction.y
	hen.attack_ended = true
	# Recuperar la gravedad
	for i in range(10):
		await hen.get_tree().create_timer(.03).timeout
		hen.gravity = prev_gravity*i/9
		print(hen.gravity)
	await hen.get_tree().create_timer(.3).timeout
	
	
func atacar(posicion_ataque: Vector2, flipped_h: bool) -> void:
	if PlayerData.puede_atacar_con_pico:
		print("¡Picotazo!")
		# Aquí iría la lógica para detectar y dañar enemigos en el área del ataque,
		# usando PlayerData.super_pico_damage para calcular el daño.
		var direccion_ataque = Vector2.RIGHT if not flipped_h else Vector2.LEFT
		# Puedes instanciar un área de daño o usar directamente collision shapes
