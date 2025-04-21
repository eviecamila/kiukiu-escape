extends Node2D
class_name SuperPico
signal grabbed
func _ready() -> void:
	$Objeto.texto = "Eso mamona, haz de cuenta\nque ya pasaste el nivel XD"
func on_grabbed() -> void:
	print("¡Ahora tengo el Super Pico!")
	PlayerData.puede_atacar_con_pico = true
	print("Puedo usar el pico para atacar.")
	queue_free() # O alguna forma de desaparecer el item

func atacar(posicion_ataque: Vector2, flipped_h: bool) -> void:
	if PlayerData.puede_atacar_con_pico:
		print("¡Picotazo!")
		# Aquí iría la lógica para detectar y dañar enemigos en el área del ataque,
		# usando PlayerData.super_pico_damage para calcular el daño.
		var direccion_ataque = Vector2.RIGHT if not flipped_h else Vector2.LEFT
		# Puedes instanciar un área de daño o usar directamente collision shapes
