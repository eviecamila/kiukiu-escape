extends CharacterBody2D
class_name Actor


@export var speed: = Vector2(300.0, 400.0)
@export var gravity: float = 1000.0  # Valor provisional para pruebas


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
"res://src/scenes/stages/map.tscn"
