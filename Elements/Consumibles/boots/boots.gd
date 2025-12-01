extends Node2D
#codigo de botas

func _ready():
	$Objeto.texto = "Obtuviste unas botas papu"
	
func on_grabbed() -> void:
	PlayerData


func on_finished() -> void:
	queue_free()
