extends Control

# --- Exportaciones de Escenas (Asigna los archivos .tscn en el Inspector) ---

# Escena 2D de ejemplo (ej: CharacterBody2D con cámara 2D)
@export var prototype_2d: PackedScene = load("res://Elements/UI/game/GameUI.tscn")
# Escena 3D de ejemplo (ej: CharacterBody3D con cámara 3D)
@export var prototype_3d: PackedScene = load("res://Elements/Levels/prototype2_5D/Level.tscn")
@export var prototype_pc: PackedScene = load("res://Elements/Levels/prototype2_5D/library/PC.tscn")
# --- Variables de Referencia ---
"res://Elements/Levels/prototype2_5D/"
# Referencia al nodo contenedor donde se agregará el prototipo (debe ser un hijo de este script)
@onready var prototype_container: Node = $PrototypeContainer

# Referencia al contenedor de botones de selección (Asegúrate de que este nombre coincida con tu escena)
@onready var buttons_container: Control = $ButtonsContainer

# Referencia al prototipo activo actualmente
var current_prototype: Node = null

# --- Funciones de Botón (Conéctalas a la señal 'pressed' de tus botones) ---

# Función llamada cuando se pulsa el botón "2D"
func _on_button_2d_pressed():
	load_prototype(prototype_2d)
	print("Modo 2D cargado.")

# Función llamada cuando se pulsa el botón "3D"
func _on_button_3d_pressed():
	load_prototype(prototype_3d)
	print("Modo 3D cargado.")
	
# --- Manejo de Input (Regreso al Menú) ---
# Se encarga de manejar la pulsación de teclas globales.
func _input(e: InputEvent):
	# Si la acción "ui_cancel" (generalmente ESC) es presionada:
	if e.is_action_pressed("ui_cancel"):
		# Llama a la función que gestiona la salida del prototipo
		return_to_main_menu()

# Función que elimina el prototipo activo y muestra el menú
func return_to_main_menu():
	# 1. Si hay un prototipo activo (es decir, estamos jugando)
	if is_instance_valid(current_prototype):
		# Eliminar el prototipo
		current_prototype.queue_free()
		current_prototype = null
		print("Prototipo descargado. Regresando al menú principal.")
		
		# 2. Mostrar el menú de selección (contenedores de botones)
		buttons_container.show()
		
		# Opcional: Liberar el cursor si estaba capturado por el juego 3D
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --- Lógica de Carga y Eliminación ---

# Función principal para instanciar y reemplazar el prototipo
func load_prototype(prototype_scene: PackedScene):
	# 1. Verificar si hay un prototipo activo y eliminarlo
	if is_instance_valid(current_prototype):
		current_prototype.queue_free()
		current_prototype = null
	
	# 2. Verificar que la escena sea válida
	if not prototype_scene:
		push_error("Error: La escena prototipo no está asignada en el Inspector.")
		return

	# 3. Instanciar la nueva escena
	var new_prototype = prototype_scene.instantiate()
	
	# 4. Agregar el nuevo prototipo al contenedor
	prototype_container.add_child(new_prototype)
	current_prototype = new_prototype
	
	# Opcional: Ocultar la UI de selección y capturar el cursor para juegos 3D
	buttons_container.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Descomentar para modo POV

# Función para la configuración inicial (si quieres empezar sin prototipo)
func _ready():
	# Aseguramos que el cursor sea visible al inicio
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Aseguramos que el menú sea visible al inicio (si no lo está por defecto)
	buttons_container.show()


func _on_button_asd_pressed() -> void:
	load_prototype(prototype_pc)
	
