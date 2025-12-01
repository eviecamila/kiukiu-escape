# Checkpoint.gd
extends Area2D

var is_active = false

func _ready():
	# Conectamos la señal de Area2D: body_entered
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Verificamos que sea el jugador y que no esté activo
	if body.is_in_in_group("player") and not is_active:
		is_active = true
		
		# 1. Llama al gestor global para registrar esta posición
		Global.set_checkpoint(self.global_position)
		
		# 2. Cambia la apariencia
		$Sprite2D.modulate = Color.YELLOW # o $AnimatedSprite2D.play("activated")
