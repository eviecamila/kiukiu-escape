extends Node2D
class_name Eye

signal got

@onready var item = $Objeto # Asegúrate de que este nodo exista y sea un Label o similar

func _ready():
	item.nombre = "Ojo de Gatita"
	update_text() # Actualiza el texto al inicio

func update_text():
	var ce = PlayerData.current_eyes_remaining
	item.texto = "Has obtenido un ojo de gatita\n"
	if ce-1>0:
		item.texto+="Ahora falta"+("n %d ojos" % [ce-1] if ce-1 !=1 else " %d ojo"% [ce-1]) + " más."
	else:
		item.texto += "Ahora ve a la meta miamor"

func on_grabbed() -> void:
	emit_signal("got")
func on_finished():
	queue_free()
