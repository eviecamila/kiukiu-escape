extends Node2D
class_name SuperHuevoDorado
signal grab_started
func _ready() -> void:
	$Objeto.texto = "Acabas de encontrar uno\nde los 3 Huevos secretos"
func _on_grab_started():
	emit_signal("grab_started")
func on_grabbed() -> void:
	PlayerData.max_active_super_eggs += 1
	#print("Ahora puedo lanzar hasta ", PlayerData.max_active_super_eggs, " Super Huevos simultáneamente.")
	

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


func on_finished() -> void:queue_free() # O alguna forma de desaparecer el item
