extends Actor

@export var stomp_impulse: float = 600.0

func get_direction() -> Vector2:
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
	super._physics_process(delta)
	
	var is_jump_interrupted: bool = Input.is_action_just_released("ui_up") and velocity.y < 0.0
	var direction: Vector2 = get_direction()
	
	# Actualizar velocidad PRIMERO
	velocity = calculate_move_velocity(velocity, direction, speed, is_jump_interrupted)
	
	# Animaciones (usa el velocity actualizado)
	if is_on_floor():
		if direction.x != 0.0:
			$AnimatedSprite2D.play("walk")
		else:
			#$AnimatedSprite2D.play("idle")
			$AnimatedSprite2D.stop()
			pass
	else:
		#$AnimatedSprite2D.play("jump")
		pass
	
	# Flip horizontal
	if direction.x > 0.0:
		$AnimatedSprite2D.flip_h = false
	elif direction.x < 0.0:
		$AnimatedSprite2D.flip_h = true
	
	move_and_slide()
	
