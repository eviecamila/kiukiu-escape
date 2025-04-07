extends Actor
class_name Hen

signal revived

@export var stomp_impulse: float = 600.0
@export var start_pos: Vector2 = Vector2.ZERO
@export var egg_scene: PackedScene = preload("res://src/scenes/objects/items/egg.tscn")
@export var throw_cooldown: float = 0.5
@export var eggs_thrown: float = 0
@export var max_eggs: float = 3

@onready var sprite = $Sprite
@onready var audio: AudioStreamPlayer = $Audio
@onready var npc_detector: Area2D = $enemy_detector2  # Asegúrate de que este nodo exista y sea de tipo Area2D
@onready var preview_btn = $PreviewAction


const buttons = {
	"btn_1":{"KB":"Z", "JS":"A"},
	"btn_2":{"KB":"X", "JS":"B"}
}

var is_dead: bool = false
var can_throw: bool = true
var jumps_remaining: int = PlayerData.max_jumps  # Saltos restantes

func _input(event: InputEvent) -> void:
	if is_dead:
		return
	# Lanzar con btn_1 sin restricciones
	if event.is_action_pressed("btn_1"):
		throw_egg()
	if event.is_action_pressed("ui_up"):
		if jumps_remaining > 0:
			jump()
			jumps_remaining -= 1
func can_press(btn:String):
	#can_press_button = true
	preview_btn.can_press(btn)
func jump():
	velocity.y = -speed.y  # Aplicar impulso hacia arriba
	print("Saltando. Saltos restantes:", jumps_remaining)
func cant_press():
	preview_btn.cant_press()

func throw_egg() -> void:
	if not can_throw or not is_physics_processing() or eggs_thrown >= max_eggs:
		print('nimadres')
		return
	print(eggs_thrown)
	print("lanzando huevo me sobas")
	eggs_thrown += 1

	var direction = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	var egg = egg_scene.instantiate()
	egg.broken_egg.connect(_on_egg_destroyed)
	egg.position = global_position + direction * 20  
	get_parent().add_child(egg)  

	# Asegurar que el huevo llegue exactamente 5 bloques adelante
	var target = global_position + direction * (5 * 32)  
	egg.throw(target)

	# Se lanza el huevo sin afectar la velocidad de la gallina
	await get_tree().create_timer(throw_cooldown).timeout
	can_throw = true

func _on_egg_destroyed()->void:
	eggs_thrown-=1

func get_direction() -> Vector2:
	if is_dead:
		return Vector2.ZERO  # Si está muerto, no se mueve

	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		-Input.get_action_strength("ui_up") if is_on_floor() and Input.is_action_just_pressed("ui_up") else 0.0
	)

	return direction
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
			sprite.play("idle")  # Si no se mueve, detener la animación
	else:
		pass
		#sprite.play("jump")  # Animación de salto
	
	# Resetear saltos si está en el suelo
	if is_on_floor():
		jumps_remaining = PlayerData.max_jumps  # Restaurar saltos disponibles cuando toca el suelo
	
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
	
	emit_signal("revived")  # Emitir la señal después de reiniciar

func restart():
	die()

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):  # Supongamos que los enemigos están en un grupo llamado "enemy"
		die()
