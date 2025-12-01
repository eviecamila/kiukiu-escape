extends CharacterBody3D

# --- Constantes y Variables ---
const SPEED = 3 # Un poco más rápido para FPS
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002 # Controla la velocidad de rotación del mouse
var startpos

# pos 0: 2.5D, pos 1: POV
const default_rotation:Vector3 = Vector3(0,0,0)
const default_pov_rotation:Vector3 = Vector3(0,0,0)
const sizes = [Vector3(.32,.32,.1), Vector3(.16,.32,.16)]

@onready var sprites: AnimatedSprite3D = $sprites
@onready var pov_camera: Camera3D = $POV # Referencia a la cámara POV
@onready var camera: Camera3D = $CAM_2_5D # Referencia a la cámara POV
@onready var hurtbox: CollisionShape3D = $Hurtbox

# Variables de rotación para el movimiento del mouse
var rotation_x = 0.0
var rotation_y = 0.0

var pov_mode = false

func _ready() -> void:
	startpos = Vector3(position.x, position.y, position.z)
	# Captura el cursor del mouse y lo esconde.
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sprites.play("idle")


func get_gravity_value() -> float:
	# Devuelve la gravedad del proyecto
	return ProjectSettings.get_setting("physics/3d/default_gravity")


# --- Control del Mouse para la Cámara ---
func _input(event):
	if event is InputEventMouseMotion:
		# Acumular movimiento horizontal (rotación del cuerpo)
		rotation_y += -event.relative.x * SENSITIVITY
		# Acumular movimiento vertical (rotación de la cámara)
		rotation_x += -event.relative.y * SENSITIVITY

		# Limitar la rotación vertical para evitar que se dé la vuelta
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("btn_2"): 
		toggle()

func toggle():
	pov_mode = !pov_mode
	camera.set_current(!pov_mode)
	pov_camera.set_current(pov_mode)

	if pov_mode:
		pov_camera.rotation = default_pov_rotation
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hurtbox.shape.set_size(sizes[1])
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		rotation = default_rotation
		hurtbox.shape.set_size(sizes[0])


# --- Lógica de Física ---
func _physics_process(delta):
	var input_dir

	if Input.is_action_just_pressed("btn_reset"):
		position = startpos

	if pov_mode:
		# Aplicar la rotación del mouse al cuerpo del personaje (eje Y)
		rotation.y = rotation_y
		# Aplicar la rotación vertical a la cámara (eje X)
		pov_camera.rotation.x = rotation_x
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 1. Aplicar la gravedad
	if not is_on_floor():
		velocity.y -= get_gravity_value() * delta

	# 2. Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Manejar el movimiento (WASD)

	# La dirección de movimiento se calcula basada en la rotación del cuerpo (la cámara)
	# y no en el transform.basis global como antes.
	var direction = Vector3.ZERO

	# Obtener el vector de avance (forward) y lateral (strafe) del personaje
	var transform_basis = global_transform.basis
	direction += transform_basis.z * input_dir.y # Z es hacia adelante/atrás
	direction += transform_basis.x * input_dir.x # X es izquierda/derecha

	direction = direction.normalized()

	if direction != Vector3.ZERO:
		# Esto asegura que la velocidad horizontal sea solo la dirección * SPEED
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Opcional: Rotar los sprites según la dirección de movimiento para el 3D
		# sprites.rotation.y = atan2(-direction.x, -direction.z)
	else:
		# Desaceleración suave
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 4. Mover y Deslizar
	move_and_slide()
