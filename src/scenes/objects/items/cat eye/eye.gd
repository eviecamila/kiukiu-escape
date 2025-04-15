extends Node2D
class_name Eye
func _ready():
	$Objeto.texto="Ay mi gatito miau miau"
func on_grabbed() -> void:
	
	print("¡Un Ojo de Gatita! ¡Ahora veo mejor!")
	PlayerData.vision_nocturna_duracion += PlayerData.vision_nocturna_duracion_base # Usando la base para el incremento
	print("Duración de visión nocturna aumentada a ", PlayerData.vision_nocturna_duracion, " segundos.")
	queue_free() # O alguna forma de desaparecer el item

# En el script del jugador o un sistema de efectos:
# func activar_vision_nocturna() -> void:
# 	if PlayerData.puede_activar_vision_nocturna and Time.get_ticks_msec() / 1000.0 > PlayerData.tiempo_fin_vision_nocturna:
# 		print("Activando visión nocturna por ", PlayerData.vision_nocturna_duracion, " segundos.")
# 		# Activar el efecto visual de visión nocturna
# 		PlayerData.puede_activar_vision_nocturna = false
# 		PlayerData.tiempo_fin_vision_nocturna = Time.get_ticks_msec() / 1000.0 + PlayerData.vision_nocturna_duracion
# 		await get_tree().create_timer(PlayerData.vision_nocturna_cooldown).timeout
# 		PlayerData.puede_activar_vision_nocturna = true
# 	elif Time.get_ticks_msec() / 1000.0 <= PlayerData.tiempo_fin_vision_nocturna:
# 		print("La visión nocturna aún está activa.")
# 	else:
# 		print("La visión nocturna está en cooldown.")
