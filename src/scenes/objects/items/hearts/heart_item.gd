extends Node2D
class_name ItemHeart
func _ready() -> void:
	$Objeto.sfx_path = "powerup/live.wav"
func on_grabbed() -> void:
	print("¡Un corazón! Me siento más fuerte.")
	PlayerData.increase_lives() # Usando la función para asegurar límites
	print("Vida normal actual: ", PlayerData.lives)
	


func on_finished() -> void:
	queue_free()
