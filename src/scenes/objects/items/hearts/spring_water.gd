extends Node2D
class_name SpringWater
var lives = Lives.get_instance()
func on_grabbed() -> void:
	print("¡Agua revitalizante! ¡Curación total!")
	lives.max_life()
	PlayerData.lives = PlayerData.max_lives
	PlayerData.golden_lives = PlayerData.max_golden_lives
	
	print("Vida normal restaurada a: ", PlayerData.lives)
	print("Vida dorada restaurada a: ", PlayerData.golden_lives)
	queue_free() # O alguna forma de desaparecer el item
