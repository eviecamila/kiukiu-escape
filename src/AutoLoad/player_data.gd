extends Node

signal updated
signal died
signal reset

# SALTOS MAXIMOS EN LA GALLINA JOTA
var max_jumps = 0
var version = "Beta 0.1.1"
# Bit para saber si se esta depurando
var debug = 0

# VIDA
var _max_lives = 3
var lives = _max_lives
var max_golden_lives = _max_lives # Inicialmente igual a max_lives
var golden_lives = 0

func set_max_lives(new_max_lives: int) -> void:
	_max_lives = new_max_lives
	max_golden_lives = new_max_lives # Aseguramos que max_golden_lives se actualice
	if lives > _max_lives:
		lives = _max_lives # Ajustar vida actual si excede el nuevo máximo
	emit_signal("updated")

func get_max_lives() -> int:
	return _max_lives

var max_lives: int: set = set_max_lives, get = get_max_lives

# SUPER HUEVO
var super_huevo_damage = 1
var puede_lanzar_super_huevo = false
var super_huevo_rango_base = 100.0
var super_huevo_rango_actual = super_huevo_rango_base
var max_active_super_eggs = 1 # Cantidad máxima de Super Huevos activos simultáneamente

# SUPER PICO
var super_pico_damage = 1
var puede_atacar_con_pico = false

# OJO DE GATITA
var vision_nocturna_duracion_base = 5.0
var vision_nocturna_duracion = 0.0 # Duración actual del efecto
var vision_nocturna_cooldown = 30.0
var puede_activar_vision_nocturna = true
var tiempo_fin_vision_nocturna = 0.0

# Otros estados del jugador (podrías expandir esto)
var has_bota_prrona = false # Para saber si tiene la bota prrona activa

func _ready():
	print("PlayerData listo.")
	emit_signal("updated") # Puedes emitir una señal al inicio si es necesario
	max_lives = _max_lives # Aseguramos la sincronización inicial usando el setter

func increase_max_lives(amount: int = 1) -> void:
	max_lives += amount

func increase_lives(amount: int = 1) -> void:
	lives = min(lives + amount, max_lives)
	emit_signal("updated")

func increase_golden_lives(amount: int = 1) -> void:
	golden_lives += amount
	emit_signal("updated")

func reset_lives() -> void:
	lives = max_lives
	golden_lives = 0
	emit_signal("updated")

func reset_stats() -> void:
	max_jumps = 1
	max_lives = 3
	lives = max_lives
	max_golden_lives = max_lives # Aseguramos la sincronización al resetear
	golden_lives = 0
	super_huevo_damage = 1
	puede_lanzar_super_huevo = false
	super_huevo_rango_base = 100.0
	super_huevo_rango_actual = super_huevo_rango_base
	max_active_super_eggs = 1
	super_pico_damage = 1
	puede_atacar_con_pico = false
	vision_nocturna_duracion_base = 5.0
	vision_nocturna_duracion = 0.0
	vision_nocturna_cooldown = 30.0
	puede_activar_vision_nocturna = true
	tiempo_fin_vision_nocturna = 0.0
	has_bota_prrona = false
	emit_signal("updated")
