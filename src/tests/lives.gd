extends Node
class_name Lives

@export var max_lives := 3
@export var golden_lives := 0
@export var current_lives := max_lives

signal health_update(normal: int, golden: int)
signal death

# Singleton
static var instance: Lives = null

func _init():
	if instance == null:
		instance = self
		reset_lives()
	else:
		queue_free()  # Evita múltiples instancias

static func get_instance() -> Lives:
	if instance == null:
		instance = Lives.new()
	return instance

func reset_lives() -> void:
	current_lives = max_lives
	golden_lives = 0
	emit_signal("health_update", current_lives, golden_lives)
func check_lives():
	if current_lives <= 0:
		emit_signal("death")
# Sobrecarga de health_plus con un solo argumento
func all_health_plus(total_health: int) -> void:
	print("Subiendo total:\n%d vidas" % [total_health])
	
	# Primero llenar las vidas normales hasta el máximo
	var normal_health_needed = max_lives - current_lives
	if total_health <= normal_health_needed:
		# Si no hay suficiente para llenar las vidas normales
		current_lives += total_health
	else:
		# Llenar las vidas normales y pasar el resto a doradas
		current_lives = max_lives
		var remaining_health = total_health - normal_health_needed
		golden_lives = min(golden_lives + remaining_health, 3)  # Máximo 3 vidas doradas
	# Emitir señal de actualización
	emit_signal("health_update", current_lives, golden_lives)
	check_lives()

# Versión existente de health_plus con dos argumentos
func health_plus(normal: int, golden: int) -> void:
	print("Subiendo:\n%d vidas doradas\n%d vidas" % [golden, normal])
	
	
	golden_lives = min(golden_lives + golden, 3)  # Máximo 3 vidas doradas
	if golden_lives<0:golden_lives = 0
	if current_lives > 0:
		current_lives = min(current_lives + normal, max_lives)
	# Emitir señal de actualización
	emit_signal("health_update", current_lives, golden_lives)
	check_lives()
func health_minus(lives: int) -> void:
	lives = abs(lives)  # Asegura que siempre sea positivo
	print("Bajando:\n%d vidas" % [lives])
	
	while lives > 0:
		if golden_lives > 0:
			golden_lives -= 1
		elif current_lives > 0:
			current_lives -= 1
		lives -= 1
	
	
	
	# Emitir señal de actualización
	emit_signal("health_update", current_lives, golden_lives)
	check_lives()
