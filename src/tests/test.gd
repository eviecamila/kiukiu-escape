extends Node2D

@onready var normal_label: Label = $UI_DEBUG_LIVES/normal
@onready var golden_label: Label = $UI_DEBUG_LIVES/gold
@onready var lives: Label = $UI_DEBUG_LIVES/debug
@onready var total_label: Label = $UI_DEBUG_LIVES/total
@onready var player = $Hen

var normal = 0
var golden = 0
var total = 0
var lives_sys = Lives.get_instance()

func _ready():
	normal_label.text = str(normal)
	golden_label.text = str(golden)
	total_label.text = str(total)
	lives_sys.connect("death", Callable(self, "on_die"))
	player.connect('revived', Callable(self, "reset"))
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
