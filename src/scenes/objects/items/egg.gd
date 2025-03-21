extends CharacterBody2D
class_name Egg

@export var speed: float = 600  
@export var gravity: float = 1000  
@export var arc_height: float = 50
signal broken_egg
var is_thrown: bool = false
var target_position: Vector2
var hitbox_active: bool = true
var broken: bool = false

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if is_thrown and not broken:
		velocity.y += gravity * delta  
		move_and_slide()
		
		# Si colisiona con layer 0 (suelo o pared), cambiar a huevo roto
		if is_on_floor() or get_last_slide_collision():
			break_egg()

func throw(target: Vector2) -> void:
	is_thrown = true
	target_position = target
	
	var direction = (target - position).normalized()
	velocity.x = direction.x * speed
	velocity.y = -sqrt(2 * gravity * arc_height)  

	if has_node("Sprite2D"):
		sprite.rotation = velocity.angle()

	# Excluir colisiones con la gallina
	collision_shape.set_deferred("disabled", true)  # Desactivar colisiones inmediatamente
	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = false  # Reactivar colisiones después de 0.1 segundos

func break_egg() -> void:
	if broken:
		return  # Evitar múltiples activaciones
	
	broken = true
	hitbox_active = false
	collision_shape.set_deferred("disabled", true)  # Desactivar colisión
	sprite.texture = preload("res://assets/kiu/egg.png")  # Cambiar sprite
	
	await get_tree().create_timer(1.0).timeout
	emit_signal("broken_egg")
	queue_free()  # Destruir después de 1 segundo
