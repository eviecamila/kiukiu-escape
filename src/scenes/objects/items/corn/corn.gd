extends Node2D
class_name Corn

enum TipoMejora {
	SUPER_PICO,
	SUPER_HUEVO
}

@export var tipo_mejora: TipoMejora = TipoMejora.SUPER_PICO

func on_grabbed() -> void:
	print("¡Un nutritivo maíz!")
	match tipo_mejora:
		TipoMejora.SUPER_PICO:
			PlayerData.super_pico_damage += 1
			print("El daño del Super Pico aumentó a ", PlayerData.super_pico_damage)
		TipoMejora.SUPER_HUEVO:
			PlayerData.super_huevo_damage += 1
			print("El daño del Super Huevo aumentó a ", PlayerData.super_huevo_damage)
	queue_free() # O alguna forma de desaparecer el item
