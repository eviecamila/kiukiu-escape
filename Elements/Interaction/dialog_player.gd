extends CanvasLayer
class_name DialogManager 

# --- Variables ---
# ELIMINADO: Ya no necesitamos scene_text, el diálogo viene en la señal.
# var scene_text: Array = [] 

var selected_text: Array = []
var in_progress: bool = false

# --- Referencias de Nodos ---
@onready var background: Control = $BG
@onready var text_label: RichTextLabel = $BG/Text

# --- Funciones Base ---

func _ready() -> void:
	background.visible = false
	
	# 🚨 ELIMINADO: Ya no cargamos metadatos en el ready.
	# scene_text = get_meta('dialogs', []) 
	
	if is_instance_valid(SignalBus):
		# Conexión correcta en Godot 4
		SignalBus.display_dialog.connect(on_display_dialog)
	else:
		printerr("ERROR: SignalBus Autoload no está disponible o no se ha cargado.")

func show_text() -> void:
	text_label.text = '[color=#000]'+selected_text.pop_front()+'[/color]'

func next_line() -> void:
	if in_progress:
		if selected_text.size() > 0:
			show_text()
		else:
			finish()

func finish() -> void:
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false # Despausar el juego

# --- Manejo de Eventos (Callback de la Señal) ---

# 🚨 CORRECCIÓN CLAVE: Ahora esperamos un Array de Strings (dialogs)
func on_display_dialog(dialogs: Array) -> void:
	
	# Si el diálogo está en curso, avanzamos de línea.
	if in_progress:
		next_line()
		return

	# Si recibimos un Array vacío o no válido, no iniciamos.
	if dialogs.is_empty():
		return
		
	# 1. Inicia un nuevo diálogo
	get_tree().paused = true
	background.visible = true
	in_progress = true
	
	# 2. Seleccionamos y duplicamos el nuevo array de texto recibido.
	# ¡USAMOS el Array recibido directamente!
	selected_text = dialogs.duplicate()
	
	# 3. Muestra la primera línea
	show_text()
