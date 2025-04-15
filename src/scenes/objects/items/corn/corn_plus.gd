extends Node2D
class_name CornPlus

enum OpcionMejora {
	AMBOS_2,
	PICO_2,
	HUEVO_2
}

@export var opcion: OpcionMejora = OpcionMejora.AMBOS_2

func on_grabbed() -> void:
	print("¡Maíz Plus! ¡Doble nutrición!")
	match opcion:
		OpcionMejora.AMBOS_2:
			PlayerData.super_pico_damage += 1
			PlayerData.super_huevo_damage += 1
			print("El daño del Super Pico aumentó a ", PlayerData.super_pico_damage)
			print("El daño del Super Huevo aumentó a ", PlayerData.super_huevo_damage)
		OpcionMejora.PICO_2:
			PlayerData.super_pico_damage += 2
			print("El daño del Super Pico aumentó en 2 a ", PlayerData.super_pico_damage)
		OpcionMejora.HUEVO_2:
			PlayerData.super_huevo_damage += 2
			print("El daño del Super Huevo aumentó en 2 a ", PlayerData.super_huevo_damage)
	queue_free() # O alguna forma de desaparecer el item
