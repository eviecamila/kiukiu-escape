extends Node2D

# Propiedades exportadas
@export var dialog_data: Array = ["Hola pinche\nputita", "Te pones bien\ncachonda hija de\ntu putamadre", "Quisiera mamarte\nElizabeth 🫦"]  # Datos del diálogo (como definiste antes)
@export var interact_radius: int = 100  # Radio de interacción
@export var interact_action: String = "btn_1"  # Acción de entrada (configurada en Project Settings)
@export var cancel_action: String = "btn_2"  # Acción de entrada (configurada en Project Settings)


# Declaraciones "onready" para nodos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var dialogue_text: Label = $DialogueText  # Ajusta si no existe
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer  # Nuevo nodo

# Estado del NPC
var is_interacting: bool = false
var current_dialog_index: int = 0
var current_text = ""
var typing_speed = 0.05  # Velocidad de escritura (ajusta según sea necesario)

func _ready():
	if not animated_sprite or not interaction_area:
		print("Error: Alguno de los nodos requeridos no existe.")
		return

	animated_sprite.play("idle")  # Animación de idle
	
	# Conectar señales usando Callable
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	if is_interacting:
		# Mostrar diálogo y manejar inputs
		process_dialog()
	else:
		# Reanudar animación si no está interactuando
		animated_sprite.play("idle")

func _input(_event):
	if is_interacting:
		return  # Ignorar inputs durante el diálogo

	if Input.is_action_just_pressed(interact_action) and is_player_near:
		start_dialog()

var is_player_near =false

func start_dialog():
	if not is_interacting and is_player_near:
		is_interacting = true
		animated_sprite.stop()  # Detener animación idle
		current_dialog_index = 0
		audio_player.stream = preload("res://assets/audio/cluck/1.ogg")  
		audio_player.play()  

		# Bloquear controles del jugador
		get_node("/root/Level 1/Node2/Hen").set_physics_process(false)

		show_next_dialog()


func show_next_dialog():
	if current_dialog_index >= dialog_data.size():
		end_dialog()
		return

	var entry = dialog_data[current_dialog_index]
	if typeof(entry) == TYPE_STRING:
		
		current_text = entry
		dialogue_text.text = ""
		start_typing()
	elif typeof(entry) == TYPE_DICTIONARY:
		for key in entry:
			var _options = entry[key]  # Prefijo con "_" para indicar que no se usa
			break
var is_typing = false  # Variable para controlar si se está escribiendo

func start_typing():
	if current_text != "":
		is_typing = true
		dialogue_text.text = ""  # Limpiar antes de empezar
		var text_to_show = ""
		audio_player.play()
		for i in range(current_text.length()):
			# Si se presiona btn_2, mostrar todo el texto de golpe
			if Input.is_action_pressed("btn_2"):
				dialogue_text.text = current_text + "\n                                  v"
				is_typing = false
				await wait_for_input()
				return

			text_to_show += current_text[i]
			if i % 30 == 0 and current_text[i] == " ":
				text_to_show += "\n"
			dialogue_text.text = text_to_show  # Actualizar el Label
			await get_tree().create_timer(typing_speed).timeout  # Esperar antes de añadir el siguiente carácter

		# Mostrar el indicador de continuación
		dialogue_text.text += "\n                                  v"
		is_typing = false
		await wait_for_input()

func wait_for_input():
	# Esperar a que el jugador presione btn_1 antes de continuar
	await get_tree().process_frame
	while not Input.is_action_just_pressed("btn_1"):
		await get_tree().process_frame

	current_dialog_index += 1
	show_next_dialog()


func process_dialog():
	# Aquí manejas la lógica de selección de opciones
	# Ejemplo para opción binaria (Sí/No):
	if Input.is_action_just_pressed("ui_accept"):
		# Procesar opción "Sí"
		handle_choice("yes")
	elif Input.is_action_just_pressed("ui_cancel"):
		# Procesar opción "No"
		handle_choice("no")

func handle_choice(choice: String):
	# Ejemplo de procesamiento de elección
	var current_entry = dialog_data[current_dialog_index]
	if typeof(current_entry) == TYPE_DICTIONARY:
		for key in current_entry:
			var options = current_entry[key]
			if choice in options:
				var next_dialog = options[choice]["dialog"]
				dialog_data = next_dialog + dialog_data.slice(current_dialog_index + 1)
				current_dialog_index = 0
				show_next_dialog()
				return
func end_dialog():
	is_interacting = false
	animated_sprite.play("idle")  
	dialogue_text.text = ""  

	audio_player.stream = preload("res://assets/audio/cluck/2.ogg")  
	audio_player.play()  

	# Reactivar controles del jugador
	get_node("/root/Level 1/Node2/Hen").set_physics_process(true)


func _on_interaction_area_body_entered(body: Node2D) -> void: is_player_near=true
func _on_interaction_area_body_exited(body: Node2D) -> void: is_player_near=false
