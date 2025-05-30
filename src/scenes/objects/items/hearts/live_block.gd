extends Node2D
class_name LiveBlock
@onready var item = $Objeto
func _ready():pass
# el Kiu Bloque aumenta vida maxima
func on_grabbed() -> void:
	print("¡Un Kiu Bloque! ¡Más vida!")
	PlayerData.max_lives += 1 # Esto actualizará automáticamente max_golden_lives
	print("Vida máxima aumentada a: ", PlayerData.max_lives)
	if PlayerData.lives < PlayerData.max_lives:
		PlayerData.increase_lives()
		print("Vida normal aumentada a: ", PlayerData.lives)
	else:
		PlayerData.increase_golden_lives()
		print("Vida dorada aumentada a: ", PlayerData.golden_lives)


func on_finished() -> void:
	queue_free()
