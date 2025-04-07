extends Node2D
@onready var normal_label: Label = $Node2D/normal
@onready var golden_label: Label = $Node2D/gold
@onready var lives: Label = $Node2D/debug
@onready var total_label: Label = $Node2D/total
@onready var player = $Hen
@onready var map_inv_menu = $MapMenu

var normal = 0
var golden = 0
var total = 0
var lives_sys = Lives.get_instance()

# Variable para controlar si se puede pausar
var can_pause: bool = true

func _input(event: InputEvent):
	if get_tree().paused:
		return  # Ignora la entrada cuando el juego está pausado
	eval_input(event)

func toggle_menu():
	# Solo alterna el estado de pausa si se permite
	if not can_pause:
		return
	
	# Alterna el estado de pausa
	can_pause = false  # Bloquea la pausa temporalmente
	get_tree().paused = not get_tree().paused
	print("Estado de pausa:", get_tree().paused)
	
	# Si el juego está pausado, muestra el menú; si no, ocúltalo
	if get_tree().paused:
		map_inv_menu.show()  # Muestra el menú
	else:
		map_inv_menu.hide()  # Oculta el menú
	
	# Restablece el permiso para pausar después de un breve retraso
	await get_tree().create_timer(0.1).timeout  # Espera 0.1 segundos
	can_pause = true

func _ready():
	normal_label.text = str(normal)
	golden_label.text = str(golden)
	total_label.text = str(total)
	lives_sys.connect("death", Callable(self, "on_die"))
	player.connect('revived', Callable(self, "reset"))
	map_inv_menu.hide()
	update_debug()

# Evento cuando fallece la gallina cuyeya
func on_die():
	$Hen.die()
	
# Evento cuando se está reseteando
func reset():
	lives_sys.reset_lives()
	update_debug()

func plusgold() -> void:
	golden += 1
	golden_label.text = str(golden)
	issue()

func minusgold() -> void:
	golden -= 1
	golden_label.text = str(golden)
	issue()

func plus() -> void:
	normal += 1
	normal_label.text = str(normal)
	issue()

func minus() -> void:
	normal -= 1
	normal_label.text = str(normal)
	issue()

func restart():
	normal = 0
	golden = 0
	total = 0
	normal_label.text = "0"
	golden_label.text = "0"
	total_label.text = "0"
	print("Vida aplicada: normales =", lives_sys.current_lives, "doradas =", lives_sys.golden_lives)

func issue() -> void:
	if lives_sys:
		lives_sys.health_plus(normal, golden)
		restart()
		update_debug()
	else:
		print("ERROR: No se encontró el sistema de vidas")

func update_debug() -> void:
	if lives_sys:
		lives.text = "Normales: %d | Doradas: %d" % [lives_sys.current_lives, lives_sys.golden_lives]
	else:
		lives.text = "ERROR: Sistema de vidas no encontrado"

func issuetotal() -> void:
	if total < 0:
		lives_sys.health_minus(total)
	else:
		lives_sys.all_health_plus(total)
	restart()
	update_debug()

func plustotal() -> void:
	total += 1
	total_label.text = str(total)
	update_debug()

func minustotal() -> void:
	total -= 1
	total_label.text = str(total)
	update_debug()

func eval_input(event: InputEvent):
	if event.is_action_pressed("ui_map"):
		toggle_menu()
