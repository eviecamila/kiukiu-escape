extends Control

signal continued

# Variables para controlar el estado del menú
var is_map = false  # false = inventario, true = mapa
var current_index = 0  # Índice para navegar entre elementos
var explored_areas = {}  # Diccionario para almacenar las áreas exploradas
var inside:  # Indica si estamos dentro del menú principal
	set = set_inside
var inventory_mode = "Tools":  # Modo inicial: "Tools" o "Items"
	set = _set_inv_mode
var inside_sub_menu = false  # Indica si estamos en el submenú
var can_use = true


@onready var inv_panel = $InventoryPanel
@onready var map_panel = $MapPanel
@onready var tools_selector = $InventoryPanel/ToolsSelector/focused:
	set = _set_t_focused
@onready var consumibles_selector = $InventoryPanel/ItemsSelector/focused:
	set = _set_i_focused
@onready var selectors = [$InventoryPanel/ToolsSelector, $InventoryPanel/ItemsSelector]
@onready var inventory_grid = $InventoryPanel/InventoryGrid
@onready var help_buttons = [$Help1, $Help2]
@onready var equipped_items = [$InventoryPanel/Item1, $InventoryPanel/Item2]

# Setter de focus de la opcion herramientas
func _set_t_focused(v):
	tools_selector.visible= v
# Setter de focus de la opcion consumibles
func _set_i_focused(v):
	consumibles_selector.visible= v
# Setter del tipo de inventario
func _set_inv_mode(v):
	inventory_mode= v
	inventory_grid.texto = v
	
# Salirse del inventario
func unfocus_inventory():
	_set_i_focused(false)
	_set_t_focused(false)
func focus_items():
	unfocus_inventory()
	if inventory_mode == "Tools":
		_set_t_focused(true)
	else:
		_set_i_focused(true)
func set_inside(v):
	$UI_Buttons.visible = not v
	inside = v
	if not inside: 
		unfocus_inventory()
	else:
		focus_items()
		
func set_inside_submenu(v):
	pass
func _ready():
	Inventory.get_instance().connect("item_used", Callable(reset_item_slot))
	set_inside(false)
	# Oculta el menú al iniciar
	map_panel.hide()
	hide()
	
	# Inicializa áreas exploradas (ejemplo: coordenadas como claves)
	explored_areas = {
		Vector2(0, 0): "Inicio",
		Vector2(1, 0): "Bosque",
		Vector2(0, 1): "Lago"
	}
	
	# Configura el inventario inicial
	
	inventory_grid.hide()  # Oculta el submenú inicialmente
	current_index = 0  # Índice inicial

	print("Menú inicializado. Modo actual: ", inventory_mode)

func _input(event: InputEvent):
	if not visible or !can_use:
		#print("Menú no visible. Ignorando entrada.")
		return  # Ignora la entrada si el menú no está visible
	for key in ["ui_map", "ui_left", "ui_up", "ui_down", "ui_select", "ui_right", "btn_1", "btn_2"]:
		if event.is_action_pressed(key):
			print("Acción recibida: ", key)
			handle_input(key)
			return

func handle_input(action: String):
	match action:
		"ui_map":
			print("Acción: Continuar juego")
			continue_game()
		
		"ui_left":
			if not inside:
				print("Acción: Alternar modo (mapa/inventario)")
				toggle_mode()
			elif is_map:
				print("Acción: Navegar mapa hacia la izquierda")
				handle_map_input(-1)  # Navega hacia la izquierda en el mapa
			else:
				print("Acción: Navegar inventario hacia la izquierda")
				handle_inventory_input(-1)  # Navega hacia la izquierda en el inventario
		
		"ui_right":
			if not inside:
				print("Acción: Alternar modo (mapa/inventario)")
				toggle_mode()
			elif is_map:
				print("Acción: Navegar mapa hacia la derecha")
				handle_map_input(1)  # Navega hacia la derecha en el mapa
			else:
				print("Acción: Navegar inventario hacia la derecha")
				handle_inventory_input(1)  # Navega hacia la derecha en el inventario
		
		"ui_up":
			if is_map:
				print("Acción: Navegar mapa hacia arriba")
				handle_map_input(Vector2.UP)  # Navega hacia arriba en el mapa
			elif inside and not inside_sub_menu:
				print("Acción: Cambiar entre Herramientas y Consumibles")
				if inventory_mode == "Tools":
					inventory_mode = "Items"
				else:
					inventory_mode = "Tools"
				focus_items()
				print("Modo de inventario cambiado a: ", inventory_mode)
		
		"ui_down":
			if is_map:
				print("Acción: Navegar mapa hacia abajo")
				handle_map_input(Vector2.DOWN)  # Navega hacia abajo en el mapa
			elif inside and not inside_sub_menu:
				print("Acción: Cambiar entre Herramientas y Consumibles")
				if inventory_mode == "Tools":
					inventory_mode = "Items"
					tools_selector.hide()
					consumibles_selector.show()
					
				else:
					inventory_mode = "Tools"
					tools_selector.show()
					_set_i_focused(false)
				print("Modo de inventario cambiado a: ", inventory_mode)
		
		"ui_select":
			if is_map:
				print("Seleccionaste el área:", explored_areas.get(current_index, "Área desconocida"))
			else:
				print("Seleccionaste un ítem del inventario")
		
		"btn_1":
			if inside and is_map:
				print("Acción: Botón 1 presionado en el mapa (sin acción definida)")
			elif inside and not inside_sub_menu:
				print("Acción: Abrir submenú")
				inside_sub_menu = true
				for s in selectors:s.hide()
				inventory_grid.show()  # Mostrar el submenú
				can_use = false
			elif inside and inside_sub_menu:
				print("Acción: Botón 1 presionado en el submenú (sin acción definida)")
			else: set_inside(true)
		
		"btn_2":
			if not inside:
				print("Acción: Continuar juego")
				continue_game()
			if inside and inside_sub_menu:
				print("Acción: Salir del submenú")
				inside_sub_menu = false
				for s in selectors:s.show()
				inventory_grid.hide()  # Ocultar el submenú
				current_index = 0  # Reiniciar índice
			elif inside:
				set_inside(false)
			print("Regresando al estado inicial")
	handle_help_texts()
func handle_help_texts():
	if not help_buttons: return
	# Dentro del menu
	if inside:
		help_buttons[0].displayed_text = "Seleccionar"
		help_buttons[1].displayed_text = "Regresar"
	# Fuera del menu
	else:
		help_buttons[0].displayed_text = "Entrar al "+ ("mapa" if is_map else"inventario")
		help_buttons[1].displayed_text = "Continuar juego"

func handle_inventory_input(direction: int):
	if inventory_mode == "Tools":
		# Navegación dentro de "Herramientas"
		var tools_size = tools_selector.get_child_count() - 1  # Excluimos el título
		current_index += direction
		current_index = clamp(current_index, 0, tools_size)
		print("Índice de herramientas actualizado: ", current_index)
	elif inventory_mode == "Items":
		# Navegación dentro de "Consumibles"
		var consumibles_size = consumibles_selector.get_child_count() - 1  # Excluimos el título
		current_index += direction
		current_index = clamp(current_index, 0, consumibles_size)
		print("Índice de consumibles actualizado: ", current_index)

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

func swap(d1, d2):
	d1.show()
	d2.hide()

func toggle_mode():
	# Alterna entre el modo inventario y el modo mapa
	is_map = not is_map
	if is_map:
		print("Cambiando a modo mapa")
		swap(map_panel, inv_panel)
	else:
		print("Cambiando a modo inventario")
		swap(inv_panel, map_panel)
	current_index = Vector2(0, 0) if is_map else 0  # Reinicia el índice según el modo

# Continuar juego
func continue_game():
	print("Continuando juego...")
	hide()
	await get_tree().create_timer(0.1).timeout
	emit_signal("continued")

func _on_left_button_pressed() -> void:
	print("Botón izquierdo presionado: Alternar modo")
	toggle_mode()

func _on_right_button_pressed() -> void:
	print("Botón derecho presionado: Alternar modo")
	toggle_mode()

func _on_show():
	print("Mostrando menú")
	show()

func _on_exit_button_pressed() -> void:
	print("Botón de salida presionado: Continuar juego")
	continue_game()


func _on_inventory_grid_exited() -> void:
	can_use = true


func equip_item(pos, item) -> void:
	equipped_items[pos]._set_item(item)
	var path = "/root/Stage/UI/TopBar/Item"+str(pos+1)
	var btn = get_node(path)
	btn._set_item(item)

func reset_item_slot(pos):
	equipped_items[pos].reset(false)
	get_parent().top_bar.reset_slot(pos)
