extends Actor
class_name Hen

signal died

@export var stomp_impulse: float = 600.0
@export var start_pos: Vector2 = Vector2.ZERO  # Usar Vector2 para la posición de reinicio

@onready var sprite = $Sprite
@onready var audio: AudioStreamPlayer= $Audio
var is_dead: bool = false  # Variable para controlar si el personaje está muerto

func get_direction() -> Vector2:
	if is_dead:
		return Vector2.ZERO  # Si está muerto, no se mueve
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		-Input.get_action_strength("ui_up") if is_on_floor() and Input.is_action_just_pressed("ui_up") else 0.0
	)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		_speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var _velocity: Vector2 = linear_velocity
	_velocity.x = _speed.x * direction.x
	if direction.y != 0:
		_velocity.y = _speed.y * direction.y
	if is_jump_interrupted:
		_velocity.y = 0.0
	return _velocity

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # Si está muerto, no procesar físicas

	super._physics_process(delta)
	
	var is_jump_interrupted: bool = Input.is_action_just_released("ui_up") and velocity.y < 0.0
	var direction: Vector2 = get_direction()
	
	# Actualizar velocidad PRIMERO
	velocity = calculate_move_velocity(velocity, direction, speed, is_jump_interrupted)
	
	# Animaciones (usa el velocity actualizado)
	if is_on_floor():
		if direction.x != 0.0:
			sprite.play("walk")
		else:
			sprite.stop()  # Si no se mueve, detener la animación
	else:
		sprite.play("jump")  # Animación de salto
	
	# Flip horizontal
	if direction.x > 0.0:
		sprite.flip_h = false
	elif direction.x < 0.0:
		sprite.flip_h = true
	
	if Input.is_action_just_pressed("btn_reset"):
		print('Reiniciando jugador')
		restart()
	
	move_and_slide()

func die():
	if is_dead:
		return  # Evitar múltiples llamadas a die()
	
	is_dead = true
	audio.stream = load("res://assets/audio/death/1.ogg")
	audio.play()
	set_physics_process(false)  # Detener las físicas
	sprite.play("die")  # Reproducir animación de muerte
	
	# Esperar 1.5 segundos antes de reiniciar
	await get_tree().create_timer(1.5).timeout
	
	# Reiniciar posición y estado
	audio.stream = load("res://assets/audio/death/2.ogg")
	audio.play()
	position = start_pos
	sprite.play("idle")  # Cambiar a animación de "idle"
	is_dead = false  # Marcar como no muerto
	print("Reiniciando en: ", start_pos)
	set_physics_process(true)  # Reanudar las físicas
	
	emit_signal("died")  # Emitir la señal después de reiniciar

func restart():
	die()

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):  # Supongamos que los enemigos están en un grupo llamado "enemy"
		die()
