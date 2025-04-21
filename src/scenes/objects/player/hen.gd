extends Actor
class_name Hen

signal revived

@export var stomp_impulse: float = 600.0
@export var start_pos: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite
@onready var audio: AudioStreamPlayer = $Audio
@onready var npc_detector: Area2D = $enemy_detector2
@onready var preview_btn = $PreviewAction

const buttons = {
	"btn_1": { "KB": "Z", "JS": "A" },
	"btn_2": { "KB": "X", "JS": "B" },
	"btn_3": { "KB": "C", "JS": "X" },
	"btn_4": { "KB": "V", "JS": "Y" }
}

var is_dead: bool = false
var jumps_remaining: int = PlayerData.max_jumps
var lives: Lives

func _ready():
	lives = Lives.get_instance()  # Usar el singleton de Lives
	lives.connect("death", Callable(restart))

func _input(event: InputEvent) -> void:
	if is_dead:
		return

	if event.is_action_pressed("btn_2"):
		handle_jump()

func can_press(btn: String):
	# Determinar el tipo de control basado en si el jugador está tocando la pantalla
	var variant = "JS" if Meta.touching else "KB"
	
	# Verificar que el botón exista en el diccionario `buttons`
	if not buttons.has(btn):
		print("Error: El botón '%s' no está definido en el diccionario `buttons`." % btn)
		return
	
	# Verificar que el tipo de control exista para el botón
	if not buttons[btn].has(variant):
		print("Error: El botón '%s' no tiene configuración para '%s'." % [btn, variant])
		return
	# Construir el identificador del botón
	var button_id = (variant + "_" + buttons[btn][variant]).to_lower()
	print(button_id)
	# Habilitar o deshabilitar el botón en la interfaz
	if preview_btn:
		preview_btn.can_press(button_id)
	else:
		print("Error: preview_btn no está definido.")
func handle_jump():
	if is_on_floor():
		jump()
	elif jumps_remaining > 0:
		jump()
		jumps_remaining -= 1

func jump():
	velocity.y = -speed.y
	print("Saltando. Saltos restantes:", jumps_remaining)

func cant_press():
	preview_btn.cant_press()

func get_direction() -> Vector2:
	if is_dead:
		return Vector2.ZERO

	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0
	)

	return direction

func calculate_move_velocity(linear_velocity: Vector2, direction: Vector2, _speed: Vector2, is_jump_interrupted: bool) -> Vector2:
	var _velocity: Vector2 = linear_velocity
	_velocity.x = _speed.x * direction.x
	if is_jump_interrupted:
		_velocity.y = 0.0
	return _velocity

func stopped_jump():
	return Input.is_action_just_released("btn_2")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	super._physics_process(delta)

	var is_jump_interrupted: bool = stopped_jump() and velocity.y < 0.0
	var direction: Vector2 = get_direction()

	velocity = calculate_move_velocity(velocity, direction, speed, is_jump_interrupted)

	if is_on_floor():
		if direction.x != 0.0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		pass

	if is_on_floor():
		jumps_remaining = PlayerData.max_jumps

	if direction.x > 0.0:
		sprite.flip_h = false
	elif direction.x < 0.0:
		sprite.flip_h = true

	if Input.is_action_just_pressed("btn_reset"):
		restart()

	move_and_slide()

func get_damage(dmg):
	if lives != null:
		print("Recibiendo daño:", dmg)
		lives.health_minus(dmg)
	else:
		print("Error: lives is null when trying to take damage!")

func die():
	if is_dead:
		return

	is_dead = true
	audio.stream = load("res://assets/audio/death/1.ogg")
	audio.play()
	set_physics_process(false)

	sprite.play("die")

	await get_tree().create_timer(1.5).timeout

	audio.stream = load("res://assets/audio/death/2.wav")
	audio.play()
	position = start_pos
	sprite.play("idle")
	is_dead = false
	print("Reiniciando en:", start_pos)
	lives.reset_lives()
	set_physics_process(true)
	emit_signal("revived")

func restart():
	print('Se murió')
	die()

func in_g(b, g):
	return b.is_in_group(g)

func on_body_entered(b: Node2D) -> void:
	print(b)
	if b == self:
		return

	if in_g(b, "fall"):
		print("Detectado contacto con fall") 
		die()

	elif in_g(b, "enemy"):
		die()

	elif in_g(b, "damage"):
		get_damage(1)
