extends Node2D
class_name SuperHuevoDorado

func _ready() -> void:
	$Objeto.texto = "Chupalos w"
func on_grabbed() -> void:
	
	PlayerData.max_active_super_eggs += 1
	print("Ahora puedo lanzar hasta ", PlayerData.max_active_super_eggs, " Super Huevos simultáneamente.")
	queue_free() # O alguna forma de desaparecer el item

# En el script del jugador (al lanzar el huevo):
# if PlayerData.puede_lanzar_super_huevo and active_super_eggs < PlayerData.max_active_super_eggs:
# 	# Instanciar y lanzar el huevo
# 	active_super_eggs += 1
#
# # En el script del proyectil del Super Huevo al destruirse:
# signal super_huevo_destruido
# emit_signal("super_huevo_destruido")
#
# # En el script del jugador (conectado a la señal):
# func _on_super_huevo_destruido():
# 	active_super_eggs -= 1
