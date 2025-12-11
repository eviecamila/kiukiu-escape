extends Control

# ======================================================================
# 1. CONFIGURACIÓN Y VARIABLES
# ======================================================================
# Referencias a los nodos de audio hijos
@onready var sfx_player: AudioStreamPlayer = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGM 
# Nodos de la escena (Asegúrate de que tus nodos se llamen así)
@onready var title_label = $Label2 # El Label que muestra "Selecciona el sexo..."
@onready var left_container = $C1 # El contenedor que contendrá las opciones
@onready var right_container = $C2 # El contenedor que contendrá las opciones
var current_question_key := 1 # Empezamos en la pregunta 1
var current_index := 0 # Índice de la opción seleccionada
var on_confirm : Callable = func(text): pass # Placeholder para una función externa (si la necesitas)
var selecting := true
var options: Array = [] # Array que contendrá los nodos Label creados dinámicamente
var selected_answers := {} # Diccionario para guardar las respuestas del usuario

# **IMPORTANTE:** Asegúrate de que esta ruta sea correcta para tu Label prototipo
const OPTION_LABEL_SCENE = preload("res://Elements/Prototypes/Form Hen/option.tscn")

var FORM := {
	1: {
		"titulo": "Selecciona el sexo biológico del ave",
		"opciones": ["Macho", "Hembra"]
	},
	2: {
		"titulo": "Selecciona la personalidad ideal",
		"opciones": [
			"Amorosa", "Protectora", "Defensora",
			"Hostil", "Depresiva", "Sumisa", "Curiosa"
		]
	},
	3: {
		"titulo": "Selecciona el rol asignado por Zeigler",
		"opciones": ["Ponedor(a)", "Reproductor(a)", "Carne"]
	},
	4: {
		"titulo": "Escala de obediencia",
		"opciones": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
	},
	5: {
		"titulo": "Consumo de alimento",
		"opciones": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
	},
	6: {
		"titulo": "Color de plumas",
		"opciones": ["Blanco", "Colorado", "Negro", "Pinto"]
	},
	7: {
		"titulo": "Temperatura corporal",
		"opciones": ["Baja", "Media", "Alta"]
	},
	8: {
		"titulo": "Resistencia al estrés",
		"opciones": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
	},
	9: {
		"titulo": "Potencial productivo",
		"opciones": ["Bajo", "Medio", "Alto", "Élite"]
	},
	10: {
		"titulo": "Factor de obediencia avanzada",
		"opciones": ["Activado", "Desactivado"]
	},
	11: {
		"titulo": "Procesando solicitud…",
		"opciones": ["Continuar"]
	}
}

# ======================================================================
# 2. INICIALIZACIÓN (Mantener)
# ======================================================================

func _ready():
	play_bgm("PC.wav")
	SignalBus.sfx.connect(play_sfx)
	SignalBus.connect("input", _input)
	_start_form()

func _start_form():
	# ¡CAMBIO CLAVE AQUÍ!
	# Ahora options debe ser la unión de los hijos de AMBOS contenedores.
	options = left_container.get_children() + right_container.get_children()
	
	_load_question(current_question_key)
# ======================================================================
# 3. LÓGICA DE CARGA DE PREGUNTA (Creación Dinámica y Distribución)
# ======================================================================

# ======================================================================
# 3. LÓGICA DE CARGA DE PREGUNTA (Creación Dinámica y Distribución)
# ======================================================================

func _load_question(key: int):
	# Chequeo de fin de formulario
	if not FORM.has(key):
		print("Formulario completado. Respuestas: ", selected_answers)
		selecting = false
		_process_results()
		return

	var question_data = FORM[key]
	
	title_label.text = question_data.titulo
	var new_options_text = question_data.opciones
	var num_options = new_options_text.size()
	
	# **Cálculo de la división equitativa**
	var split_point = (num_options + 1) / 2
	
	# Reinicializamos la lista 'options' para que el nuevo orden sea correcto.
	options = []
	
	# 1. Asegurarse de que existan suficientes Labels (nodos children)
	# Mantenemos esta lógica ya que crea los Labels necesarios de forma eficiente.
	while left_container.get_child_count() + right_container.get_child_count() < num_options:
		var new_label = OPTION_LABEL_SCENE.instantiate()
		# Lo agregamos temporalmente al contenedor izquierdo, ya que lo reordenaremos
		left_container.add_child(new_label)
		
	# 2. **LIMPIAR Y REORDENAR:** Movemos los Labels al array 'options' en orden lógico (0, 1, 2, 3...)
	# y los reasignamos al contenedor visual correcto (C1 o C2).
	
	# Obtenemos todos los Labels existentes de ambos contenedores para reordenarlos
	var all_labels = left_container.get_children() + right_container.get_children()
	
	# Eliminamos todos los hijos para reinsertarlos en el orden correcto
	for child in left_container.get_children():
		left_container.remove_child(child)
	for child in right_container.get_children():
		right_container.remove_child(child)

	# Asignar texto y reinsertar en el orden deseado (0, 1, 2, 3, 4, 5, 6...)
	for i in range(num_options):
		var label = all_labels[i]
		
		# Asignar texto
		label.text = new_options_text[i]
		label.visible = true
		
		# Reasignar al contenedor correcto
		if i < split_point:
			left_container.add_child(label) # 0, 1, 2, 3
		else:
			right_container.add_child(label) # 4, 5, 6
			
		# Añadir al array maestro 'options' en el orden lógico (0, 1, 2, 3, 4, 5, 6...)
		options.append(label)
		
	# 3. Ocultar los Labels sobrantes (si los hay)
	for i in range(num_options, all_labels.size()):
		all_labels[i].visible = false

	# Visibilidad de los contenedores
	left_container.visible = true
	right_container.visible = num_options > split_point
			
	# 4. Resetear y marcar la selección
	current_index = 0
	_update_selection()

# ======================================================================
# 4. MANEJO DE INPUT (Mantener)
# ======================================================================

func _input(event):
	if not selecting:
		return

	var visible_options = options.filter(func(n): return n.visible).size()
	if visible_options == 0:
		return
	
	# Usamos el split_point calculado en _load_question
	var split_point = (visible_options + 1) / 2
	var new_index = current_index

	if event.is_action_pressed("ui_down"):
		# Si estamos en la base de la columna izquierda (p. ej., Hostil, índice 3)
		# Y la columna derecha existe (split_point < visible_options)
		if current_index == split_point - 1 and visible_options > split_point:
			# Saltamos a la parte superior de la columna derecha (Sumisa, índice 4)
			new_index = split_point
		
		# Si estamos en la base de la columna derecha (p. ej., Curiosa, índice 6)
		# Regresamos a la parte superior de la columna izquierda (Amorosa, índice 0)
		elif current_index == visible_options - 1:
			new_index = 0
		
		# Movimiento normal hacia abajo
		else:
			new_index += 1

	elif event.is_action_pressed("ui_up"):
		# Si estamos en la parte superior de la columna derecha (p. ej., Sumisa, índice 4)
		# Saltamos a la base de la columna izquierda (Hostil, índice 3)
		if current_index == split_point:
			new_index = split_point - 1
			
		# Si estamos en la parte superior de la columna izquierda (Amorosa, índice 0)
		# Saltamos a la base de la columna derecha (Curiosa, índice 6)
		elif current_index == 0:
			new_index = visible_options - 1
			
		# Movimiento normal hacia arriba
		else:
			new_index -= 1
			
	# **NAVEGACIÓN POR COLUMNA (Izquierda/Derecha)**
	elif event.is_action_pressed("ui_right"):
		# Si estamos en la columna izquierda, saltamos a la columna derecha
		if current_index < split_point:
			# El salto es de split_point posiciones, si el resultado no excede el límite
			var target_index = current_index + split_point
			new_index = min(target_index, visible_options - 1)
			
		# Si ya estamos en la columna derecha, volvemos al inicio de la izquierda
		else:
			new_index = current_index % split_point

	elif event.is_action_pressed("ui_left"):
		# Si estamos en la columna derecha, saltamos a la columna izquierda
		if current_index >= split_point:
			# El salto es de -split_point posiciones (ej: 4 -> 4-4=0)
			var target_index = current_index - split_point
			new_index = target_index
			
		# Si ya estamos en la columna izquierda, volvemos al final de la columna derecha
		else:
			# Saltamos al final de la lista, luego ajustamos a la columna derecha
			new_index = visible_options - 1

	elif event.is_action_pressed("ui_accept"):
		_handle_accept()
		return # Evitamos llamar a _update_selection dos veces
		
	# Aplicar el nuevo índice y actualizar solo si hubo un movimiento
	if new_index != current_index:
		current_index = new_index
		_update_selection()

func _handle_accept():
	# Obtener el texto de la opción seleccionad
	# CORRECCIÓN: Usar strip_prefix para eliminar el puntero '► ' (solución al error anterior)
	var selected_text = options[current_index].text.replace("► ", "")
	
	# 1. Guardar la respuesta
	var question_title = FORM[current_question_key].titulo
	selected_answers[question_title] = selected_text
	
	# 2. Si se definió una función externa, llamarla
	if on_confirm and current_question_key != FORM.keys().back():
		on_confirm.call(selected_text)
	SignalBus.emit_signal("sfx", "PC/select.wav")
	# 3. Mover a la siguiente pregunta
	current_question_key += 1
	_load_question(current_question_key)


func _update_selection():
	# Asegúrate de que solo se modulan y cambian las opciones visibles
	var visible_options = options.filter(func(n): return n.visible)
	
	for i in range(visible_options.size()):
		var label = visible_options[i]
		
		# CORRECCIÓN: Eliminar el marcador '► ' de todas (solución al error anterior)
		label.text = label.text.replace("► ", "")
		
		if i == current_index:
			label.modulate = Color(0,1,0) 	# Verde brillante (seleccionado)
			label.text = "► " + label.text
		else:
			label.modulate = Color(0.2,0.8,0.2) # Verde tenue (no seleccionado)

# ======================================================================
# 5. PROCESAMIENTO DE RESULTADOS FINALES (Giro Narrativo)
# ======================================================================

func _process_results():
	# Desactivamos la interfaz para indicar el final
	selecting = false
	left_container.visible = false
	right_container.visible = false
	
	# Mensaje final del sistema (La PC te habla directamente)
	var final_message = ""
	final_message += "ANÁLISIS DE DATOS COMPLETADO.\n\n"
	final_message += "RESULTADO DEL SISTEMA Z-1.0:\n\n"
	final_message += "APRECIADO USUARIO:\n"
	final_message += "Hemos registrado cuidadosamente sus parámetros ideales para el ave.\n\n"
	final_message += "Sin embargo, si tuviera la capacidad real de seleccionar los "
	final_message += "parámetros de la vida\n\na voluntad, en este momento usted no "
	final_message += "estaría configurando una gallinita.\n\n"
	final_message += "USTED YA SERÍA RICO, GUAPO Y EXITOSO."
	
	# Mostrar el mensaje final en el título o en un nuevo Label de texto
	title_label.text = final_message
	
	# Opcional: Puedes usar un Timer o AnimationPlayer para hacer el texto typewriter
	# Por ahora, simplemente lo mostramos.
	
	print("\n--- MENSAJE FINAL DEL SISTEMA Z-1.0 ---")
	print(final_message)
	
	# **TODO:** Esperar input del usuario para volver al menú principal o cerrar
	# Ejemplo: get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
# ==============================================================================
# 1. FUNCIÓN PARA EFECTOS DE SONIDO (SFX) - Reproducción ÚNICA
# ==============================================================================
# @param path: La ruta al archivo .wav o .ogg (ej: "assets/audio/player/hit.wav")
func play_sfx(path: String):
	# Cargar el archivo de audio
	
	var audio_stream = load("res://Assets/audio/sfx/" + path)
	print("playing "+ str(audio_stream))
	# 1. Asignar el stream al reproductor SFX
	sfx_player.stream = audio_stream
	
	# 2. Desactivar el bucle (loop) para SFX
	# NOTA: En Godot 4, el loop se controla en el stream. 
	# Asegúrate de que tu archivo de audio no tenga el loop activado por defecto.
	
	# 3. Reproducir el SFX (solo se reproduce una vez)
	sfx_player.play()
	print("Audio Manager: Reproduciendo SFX desde ", path)


# ==============================================================================
# 2. FUNCIÓN PARA MÚSICA DE FONDO (BGM) - Reproducción en LOOP
# ==============================================================================
# @param path: La ruta al archivo de música
# @param volume_db: El volumen opcional (ej: -5.0)
func play_bgm(path: String, volume_db: float = 0.0):
	
	# 1. Detener la música actual (para evitar superposición)
	if bgm_player.playing:
		bgm_player.stop()

	# Cargar el archivo de audio
	var audio_stream = load("res://Assets/audio/bgm/" + path)
	
	# 2. Asignar el stream y activar el bucle (loop)
	if audio_stream is AudioStreamWAV:
		# Debes configurar la propiedad 'loop' en el recurso AudioStream 
		# (usualmente se hace en el Inspector del recurso, NO desde el código).
		# Para forzarlo en código, a veces se requiere duplicar el recurso, 
		# pero lo más limpio es asegurarse de que el archivo de música tenga
		# la propiedad 'Loop' o 'Loop Mode' activada en su Inspector.
		
		# En Godot 3:
		# if audio_stream.has_method("set_loop"): audio_stream.set_loop(true)
		# En Godot 4, es más complejo, lo mejor es editar el Stream en el editor.
		pass # Asumimos que el recurso de audio .ogg o .mp3 ya tiene el loop activado en el Inspector.

	bgm_player.stream = audio_stream
	bgm_player.volume_db = volume_db
	
	# 3. Reproducir
	bgm_player.play()
	print("Audio Manager: Reproduciendo BGM en loop desde ", path)


# Función para detener BGM (útil para pantallas de pausa o carga)
func stop_bgm():
	bgm_player.stop()
	print("Audio Manager: BGM detenido.")
