extends CharacterBody2D
class_name Hen
# --- Constantes y Propiedades ---
const SPEED = 400.0  # Velocidad de movimiento horizontal
const JUMP_VELOCITY = 500.0 # Fuerza de salto vertical
const MAX_JUMPS = 1  # Salto simple (cambia a 2 para doble salto)

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var audio: AudioStreamPlayer = $Audio # Asegúrate de que este nodo exista
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Obtiene la gravedad del proyecto

var jumps_remaining: int = MAX_JUMPS
var spawn_point: Vector2

func _ready() -> void:
	# Inicializa el punto de aparición al inicio
	spawn_point = position
	SignalBus.connect("input", _input)
	# Carga el stream de audio para el salto (¡AJUSTA LA RUTA SI ES NECESARIO!)



# --- Detección de Entrada (Jump) ---
func _input(event: InputEvent) -> void:
	# Detecta el botón de salto (btn_2)
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up"): 
		handle_jump()
	if event.is_action_pressed("btn_reset"):
		restart()
	


# --- Lógica de Salto ---

func handle_jump():
	if is_on_floor():
		jump()
	elif jumps_remaining > 0: # Lógica para doble salto (si MAX_JUMPS > 1)
		jump()
		jumps_remaining -= 1

func jump():
	# Aplica la velocidad de salto (negativo para ir hacia arriba)
	velocity.y = -JUMP_VELOCITY 
	# Reproduce el sonido de salto
	print("jumping, emitiendo sonido")
	SignalBus.emit_signal("sfx", "hen/jump.wav")


# --- Lógica de Movimiento y Física ---

func get_direction() -> Vector2:
	# Obtiene la dirección del movimiento horizontal
	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0 # El movimiento vertical se maneja por gravedad/salto
	)
	return direction


func _physics_process(delta: float) -> void:
	var direction: Vector2 = get_direction()

	# 1. Aplicar la gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Asignar la velocidad horizontal
	velocity.x = direction.x * SPEED

	# 3. Restablecer saltos en el suelo y manejar animación
	if is_on_floor():
		jumps_remaining = MAX_JUMPS
		
		if direction.x != 0.0:
			sprite.play("walk")
			# Voltear el sprite según la dirección
			sprite.flip_h = direction.x < 0.0
		else:
			sprite.play("idle")
	# Nota: Aquí se podría añadir lógica de animación "jump" o "fall" para el aire
	
	# 4. Mover y Deslizar
	move_and_slide()

# --- Función de Utilidad (Mínima) ---

func restart():
	# Resetea la posición al spawn_point y detiene el movimiento
	position = spawn_point
	velocity = Vector2.ZERO
