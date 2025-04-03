extends Node2D
class_name NPCDialog

# Exportar propiedades
@export var typing_speed: float = 0.05  # Velocidad de escritura

# Referencias a nodos
@onready var dialogue_box: Panel = $Panel
@onready var sprite: Sprite2D = $Sprite  # Nodo Sprite para mostrar el NPC
@onready var dialogue_text: Label = $Panel/BG/BoxContainer/Text  # Nodo Label para mostrar el texto del diálogo
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Estado del diálogo
var current_texts: Array = []
var current_text = ""
var current_index: int = 0
var is_typing: bool = false
var npc: NPC = null  # Referencia al NPC actual

func _init() -> void:
	visible = false

func set_data(dialogs: Array):
	# Configurar los diálogos del NPC
	current_texts = dialogs
	show_next_dialog()

func show_next_dialog():
	if current_index >= current_texts.size():
		end_dialog()
		return

	var entry = current_texts[current_index]
	if typeof(entry) == TYPE_STRING:
		current_text = entry
		dialogue_text.text = ""  # Limpiar el texto antes de mostrar el siguiente diálogo
		start_typing()
	elif typeof(entry) == TYPE_DICTIONARY:
		for key in entry:
			show_options(entry[key])
			break

func start_typing():
	is_typing = true
	var text_to_show = ""
	var char_count = 0  # Contador de caracteres para manejar saltos de línea
	for i in range(current_text.length()):
		if Input.is_action_pressed("btn_2"):  # Saltar animación de escritura
			dialogue_text.text = current_text
			is_typing = false
			await wait_for_input()
			return

		text_to_show += current_text[i]
		char_count += 1

		# Insertar un salto de línea si se alcanzan 30 caracteres y el siguiente carácter es un espacio
		if char_count >= 30 and current_text[i] == " ":
			text_to_show += "\n"
			char_count = 0  # Reiniciar el contador de caracteres

		dialogue_text.text = text_to_show
		await get_tree().create_timer(typing_speed).timeout

	is_typing = false
	await wait_for_input()

func wait_for_input():
	while not Input.is_action_just_pressed("btn_1"):
		await get_tree().process_frame
	current_index += 1
	show_next_dialog()

func show_options(options: Dictionary):
	dialogue_text.text = ""  # Limpiar texto
	for option in options:
		var button = Button.new()
		button.text = option
		#button.connect("pressed", Callable(self, "_on_option_selected"), [option, options[option]])
		#options_container.add_child(button)

func _on_option_selected(option: String, data: Dictionary):
	# Procesar la selección del jugador
	current_texts = data["dialog"] + current_texts.slice(current_index + 1)
	current_index = 0
	show_next_dialog()

func end_dialog():
	# Ocultar el diálogo
	visible = false

	# Notificar al NPC que el diálogo ha terminado
	if npc:
		npc.end_dialog()

	# Resetear el estado del diálogo
	reset_dialog()

func reset_dialog():
	# Limpiar todos los datos del diálogo
	current_texts = []
	current_text = ""
	current_index = 0
	is_typing = false
	npc = null

	# Limpiar el texto y la textura del sprite
	dialogue_text.text = ""
	sprite.texture = null

func dialog(npc_instance: NPC):
	get_node("/root/Stage/C/SVPC/SVP/Node2/Hen").set_physics_process(false)
	# Guardar la referencia al NPC
	npc = npc_instance

	# Configurar los diálogos del NPC
	set_data(npc.dialog_data)

	# Cargar la textura estática del NPC
	if npc.npc_resource and npc.npc_resource.img:
		sprite.texture = npc.npc_resource.img

	# Hacer visible el diálogo
	visible = true

func get_npc_text_color() -> String:
	# Obtener el color del texto según el tipo de NPC
	var npc_type = npc.type
	return npc.types.get(npc_type, {}).get("text_color", "fff")  # Valor predeterminado: blanco (#fff)

func _process(delta):
	if is_typing:
		return  # Ignorar inputs mientras se escribe
