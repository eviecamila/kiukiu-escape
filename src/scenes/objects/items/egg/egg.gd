extends Node2D
class_name SuperHuevo

#var proyectil_scene: PackedScene = preload("res://src/scenes/proyectiles/super_huevo_proyectil.tscn") # Asegúrate de tener la escena del proyectil

func on_grabbed() -> void:
	print("¡Obtuve el Super Huevo!")
	if not PlayerData.puede_lanzar_super_huevo:
		PlayerData.puede_lanzar_super_huevo = true
		print("Ahora puedo lanzar proyectiles.")
	else:
		PlayerData.super_huevo_rango_actual += PlayerData.super_huevo_rango_base
		print("El rango del Super Huevo aumentó a ", PlayerData.super_huevo_rango_actual, " píxeles.")
	queue_free() # O alguna forma de desaparecer el item

#func lanzar(posicion_inicial: Vector2, flipped_h: bool) -> void:
	#if PlayerData.puede_lanzar_super_huevo:
		#var direccion = Vector2.RIGHT if not flipped_h else Vector2.LEFT
		#var proyectil = proyectil_scene.instantiate()
		#get_parent().add_child(proyectil)
		#proyectil.global_position = posicion_inicial
		#proyectil.direccion = direccion
		#proyectil.rango = PlayerData.super_huevo_rango_actual
		## El proyectil deberá tener lógica para moverse, caer al final del rango o al golpear un enemigo
