extends Node2D
class_name SpringWater

func on_grabbed() -> void:
	print("¡Agua revitalizante! ¡Curación total!")
	PlayerData.lives = PlayerData.max_lives
	PlayerData.golden_lives = PlayerData.max_golden_lives
	print("Vida normal restaurada a: ", PlayerData.lives)
	print("Vida dorada restaurada a: ", PlayerData.golden_lives)
	queue_free() # O alguna forma de desaparecer el item
