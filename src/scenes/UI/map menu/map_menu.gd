extends Control

# Variables para controlar el estado del menú
var is_map = false  # false = inventario, true = mapa
var current_index = 0  # Índice para navegar entre elementos
var explored_areas = {}  # Diccionario para almacenar las áreas exploradas
var inside = false
@onready var inv_panel = $InventoryPanel
@onready var map_panel = $MapPanel
func _ready():
	# Oculta el menú al iniciar
	map_panel.hide()
	hide() 
	# Inicializa áreas exploradas (ejemplo: coordenadas como claves)
	explored_areas = {
		Vector2(0, 0): "Inicio",
		Vector2(1, 0): "Bosque",
		Vector2(0, 1): "Lago"
	}

func _input(event: InputEvent):
	if not visible:
		return  # Ignora la entrada si el menú no está visible
	for key in ["ui_map", "ui_left", "ui_up", "ui_down", "ui_select", "ui_right", "btn_1", "btn_2"]:
		if event.is_action_pressed(key):
			handle_input(key);return
func handle_input(action: String):
	match action:
		"ui_map":continue_game()
		"ui_left":
			if not inside:toggle_mode()
			elif is_map:handle_map_input(-1)  # Navega hacia la izquierda en el mapa
			else:handle_inventory_input(-1)  # Navega hacia la izquierda en el inventario
		"ui_right":
			if not inside: toggle_mode()
			elif is_map: handle_map_input(1)  # Navega hacia la derecha en el mapa
			else: handle_inventory_input(1)  # Navega hacia la derecha en el inventario
		"ui_up":
			if is_map: handle_map_input(Vector2.UP)  # Navega hacia arriba en el mapa
		"ui_down":
			if is_map: handle_map_input(Vector2.DOWN)  # Navega hacia abajo en el mapa
		"ui_select":
			if is_map:
				print("Seleccionaste el área:", explored_areas.get(current_index, "Área desconocida"))
			else:
				print("Seleccionaste un ítem del inventario")
		"btn_1": inside = true
		"btn_2":
			if not inside:
				continue_game()
				return
			inside = false


func handle_inventory_input(direction: int):
	# Simula la navegación en el inventario
	var inventory_size = 5  # Ejemplo: tamaño del inventario
	current_index += direction
	current_index = clamp(current_index, 0, inventory_size - 1)  # Asegura que el índice esté dentro de los límites
	print("Índice de inventario:", current_index)

func handle_map_input(direction):
	# Navega por el mapa usando un índice basado en coordenadas
	if typeof(direction) == TYPE_VECTOR2:
		# Movimiento vertical (arriba/abajo)
		var new_position = current_index + direction
		if explored_areas.has(new_position):
			current_index = new_position
			print("Movido a:", explored_areas[current_index])
		else:
			print("Área no explorada")
	else:
		# Movimiento horizontal (izquierda/derecha)
		var new_position = current_index + Vector2(direction, 0)
		if explored_areas.has(new_position):
			current_index = new_position
			print("Movido a:", explored_areas[current_index])
		else:
			print("Área no explorada")

func swap(d1,d2):
	d1.show();d2.hide()

func toggle_mode():
	# Alterna entre el modo inventario y el modo mapa
	is_map = not is_map
	if is_map: swap(map_panel,inv_panel)
	else: swap(inv_panel, map_panel)
	current_index = Vector2(0, 0) if is_map else 0  # Reinicia el índice según el modo

# Continuar juego
func continue_game():get_parent().toggle_menu()


func _on_left_button_pressed() -> void: toggle_mode()


func _on_right_button_pressed() -> void: toggle_mode()

	

func _on_exit_button_pressed() -> void: continue_game()
