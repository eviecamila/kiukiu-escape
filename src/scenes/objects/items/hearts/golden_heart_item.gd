extends Node2D

func _ready():
	$Objeto.sfx_path = "powerup/g_live.wav"

func on_grabbed() -> void:
	print("¡Un corazón! Me siento más fuerte.")
	PlayerData.increase_golden_lives()
	print("Vida normal actual: ", PlayerData.lives)
	queue_free() # O alguna forma de desaparecer el item
