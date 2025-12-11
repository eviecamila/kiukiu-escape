extends CharacterBody3D

# --- Constantes y Variables ---
const SPEED = 3
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.002 
var startpos

# pos 0: 2.5D, pos 1: POV
const default_rotation:Vector3 = Vector3(0,0,0)
const default_pov_rotation:Vector3 = Vector3(0,0,0)
const sizes = [Vector3(.32,.32,.1), Vector3(.16,.32,.16)]

@onready var sprites: AnimatedSprite3D = $sprites
@onready var pov_camera: Camera3D = $POV
@onready var camera: Camera3D = $CAM_2_5D
@onready var hurtbox: CollisionShape3D = $Hurtbox

# **REFERENCIA:** Hijo de $POV
@onready var interaction_raycast: RayCast3D = $POV/RayCast3D

# Variables de Estado de Interacción
var rotation_x = 0.0
var rotation_y = 0.0
var pov_mode = false
var pc_camera_is_active: bool = false # Pausa el movimiento
var current_pc_node: Node3D = null # Referencia al nodo PC detectado por el RayCast

func _ready() -> void:
	startpos = Vector3(position.x, position.y, position.z)
	sprites.play("idle")
	SignalBus.PC_CAM.connect(_on_pc_cam)
	
	# Control del RayCast: Se habilita en toggle()
	if interaction_raycast:
		interaction_raycast.enabled = false


func get_gravity_value() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity")

# --- Señal del PC ---
func _on_pc_cam(value: bool):
	pc_camera_is_active = value
	
	# Al salir de la PC, restaurar el control del mouse
	if !pc_camera_is_active:
		if pov_mode:
			pov_camera.set_current(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
		else:
			camera.set_current(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 


func _input(event):
	
	if pc_camera_is_active:
		# Bloquear todo input mientras la cámara del PC está activa
		return 
		
	# Input de MOVIMIENTO del Mouse
	if event is InputEventMouseMotion:
		rotation_y += -event.relative.x * SENSITIVITY
		rotation_x += -event.relative.y * SENSITIVITY
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("btn_2"): 
		if event is InputEventKey or event is InputEventMouseButton:
			toggle()
			
	# Lógica de Interacción con btn_1 (SOLO ENTRAR)
	if event.is_action_pressed("btn_1"):
		if current_pc_node != null and pov_mode:
			# ENTRAR a la PC
			current_pc_node.toggle_pc_camera()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
			return


func toggle():
	pov_mode = !pov_mode
	camera.set_current(!pov_mode)
	pov_camera.set_current(pov_mode)
	
	# Control del RayCast: Solo activo en modo POV
	if interaction_raycast:
		interaction_raycast.enabled = pov_mode

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
	
	# --- 1. Control de Pausa (PC ACTIVO) ---
	if pc_camera_is_active:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return # Pausa y salir
		
	# --- 2. Detección de RayCast (Solo en POV) ---
	current_pc_node = null # Limpiar en cada frame
	
	# Solo intentar detección si RayCast está habilitado
	if interaction_raycast and interaction_raycast.is_enabled():
		
		interaction_raycast.force_raycast_update()
		
		if interaction_raycast.is_colliding():
			var collider = interaction_raycast.get_collider()
			
			# Buscar la raíz de la escena (PC)
			var root_pc = collider.get_owner()
			
			# **VERIFICAR NOMBRE:** Si el nodo raíz es "PC" (como en tu jerarquía)
			if root_pc and root_pc.name.contains("PC"):
				current_pc_node = root_pc
				print("Mirando la PC. Presione btn_1 para interactuar.")

	# --- 3. Resto del Movimiento ---
	
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

	# Aplicar la gravedad
	if not is_on_floor():
		velocity.y -= get_gravity_value() * delta

	# Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Manejar el movimiento
	var direction = Vector3.ZERO
	var transform_basis = global_transform.basis
	direction += transform_basis.z * input_dir.y 
	direction += transform_basis.x * input_dir.x 

	direction = direction.normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Mover y Deslizar
	move_and_slide()
