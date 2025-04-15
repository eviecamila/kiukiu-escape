extends Actor
class_name Hen

signal revived

@export var stomp_impulse: float = 600.0
@export var start_pos: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite
@onready var audio: AudioStreamPlayer = $Audio
@onready var npc_detector: Area2D = $enemy_detector2 # Asegúrate de que este nodo exista y sea de tipo Area2D
@onready var preview_btn = $PreviewAction


const buttons = {
	"btn_1":{"KB":"Z", "JS":"A"},
	"btn_2":{"KB":"X", "JS":"B"}
}

var is_dead: bool = false
var jumps_remaining: int = PlayerData.max_jumps # Saltos restantes
var lives = Lives.new()
func _ready():
	lives.connect("death", restart)
func _input(event: InputEvent) -> void:
	if is_dead:
		return
	
	# Verificar si se presiona el botón de salto
	if event.is_action_pressed("btn_2"):
		handle_jump()
func can_press(btn:String):
	#can_press_button = true
	preview_btn.can_press(btn)
# Función para manejar el salto
func handle_jump():
	if is_on_floor():
		# Salto base desde el suelo
		print("Salto base desde el suelo")
		jump()
	elif jumps_remaining > 0:
		# Saltos adicionales en el aire
		print("Saltando en el aire. Saltos restantes:", jumps_remaining)
		jump()
		jumps_remaining -= 1
func jump():
	velocity.y = -speed.y # Aplicar impulso hacia arriba
	print("Saltando. Saltos restantes:", jumps_remaining)
func cant_press():
	preview_btn.cant_press()

func get_direction() -> Vector2:
	if is_dead:
		return Vector2.ZERO # Si está muerto, no se mueve

	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0
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
	if is_jump_interrupted:
		_velocity.y = 0.0
	return _velocity

func stopped_jump():
	return Input.is_action_just_released("btn_2")

func _physics_process(delta: float) -> void:
	if is_dead:
		return # Si está muerto, no procesar físicas
	super._physics_process(delta)

	var is_jump_interrupted: bool = stopped_jump() and velocity.y < 0.0
	var direction: Vector2 = get_direction()

	# Actualizar velocidad PRIMERO
	velocity = calculate_move_velocity(velocity, direction, speed, is_jump_interrupted)

	# Animaciones (usa el velocity actualizado)
	if is_on_floor():
		if direction.x != 0.0:
			sprite.play("walk")
		else:
			sprite.play("idle") # Si no se mueve, detener la animación
	else:
		pass
		#sprite.play("jump") # Animación de salto

	# Resetear saltos si está en el suelo
	if is_on_floor():
		jumps_remaining = PlayerData.max_jumps # Restaurar saltos disponibles cuando toca el suelo

	# Flip horizontal
	if direction.x > 0.0:
		sprite.flip_h = false
	elif direction.x < 0.0:
		sprite.flip_h = true

	if Input.is_action_just_pressed("btn_reset"):
		print('Reiniciando jugador')
		restart()

	move_and_slide()
func get_damage(dmg):
	lives.health_minus(dmg)
	
func die():
	
	if is_dead:
		return # Evitar múltiples llamadas a die()

	is_dead = true
	audio.stream = load("res://assets/audio/death/1.ogg")
	audio.play()
	set_physics_process(false) # Detener las físicas
	sprite.play("die") # Reproducir animación de muerte

	# Esperar 1.5 segundos antes de reiniciar
	await get_tree().create_timer(1.5).timeout

	# Reiniciar posición y estado
	audio.stream = load("res://assets/audio/death/2.wav")
	audio.play()
	position = start_pos
	sprite.play("idle") # Cambiar a animación de "idle"
	is_dead = false # Marcar como no muerto
	print("Reiniciando en: ", start_pos)
	lives.reset_lives()
	set_physics_process(true) # Reanudar las físicas
	emit_signal("revived") # Emitir la señal después de reiniciar

func restart():
	print('se mudio')
	die()
func in_g(b, g):
	return b.is_in_group(g)
func on_body_entered(b: Node2D) -> void:
	print(b)
	# Ignorar colisiones consigo mismo
	if b == self: return
	# Verificar si el cuerpo pertenece al grupo "Fall"
	elif in_g(b, "fall"):
		print("Detectado contacto con fall")
		die()  # Ejemplo de lógica para morir al entrar en contacto con la línea de caída

	# Verificar si el cuerpo pertenece al grupo "enemy"
	elif in_g(b, "enemy"):
		die()

	# Manejar otras colisiones
	elif in_g(b, "damage"):
		get_damage(1)
