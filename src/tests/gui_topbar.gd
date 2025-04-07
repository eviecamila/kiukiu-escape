extends Control

# Escala para los corazones
const HEART_SCALE: float = 2.5

# Referencias a los nodos de los corazones
@onready var heart_nodes = [
	$Heart,   # Normal (Heart1)
	$Heart2,  # Normal (Heart2)
	$Heart3,  # Normal (Heart3)
	$Heart4,  # Dorado (Heart4)
	$Heart5,  # Dorado (Heart5)
	$Heart6   # Dorado (Heart6)
]
@onready var text = $Label
var states = {
	1: "full",
	0: "empty"
}

# Índices de corazones normales y dorados
const NORMAL_HEART_INDICES = [0, 1, 2]  # Heart1, Heart2, Heart3
const GOLDEN_HEART_INDICES = [3, 4, 5]  # Heart4, Heart5, Heart6

# Singleton Lives
var lives_instance: Lives = Lives.get_instance()

func _ready() -> void:
	# Aplicar escala a los corazones
	for i in range(heart_nodes.size()):
		var heart = heart_nodes[i]
		if heart:
			heart.scale = Vector2(HEART_SCALE, HEART_SCALE)
			heart.visible = true
		else:
			push_error("Nodo de corazón faltante en heart_nodes[%d]" % i)
	
	# Conectar señales del singleton Lives
	lives_instance.connect("health_update", Callable(self, "_on_health_update"))
	lives_instance.connect("death", Callable(self, "_on_death"))
	
	# Inicializar la visualización de las vidas
	_on_health_update(lives_instance.current_lives, lives_instance.golden_lives)


#DEBUG: Se testea si sube o baja la vida 

#func _input(event: InputEvent) -> void:
	## Detectar si se presiona btn_1 para subir vidas doradas
	#if event.is_action_pressed("btn_1"):
		#print("subir 1")
		#lives_instance.all_health_plus(1)  # Sumar 1 vida dorada
	## Detectar si se presiona btn_2 para recibir daño
	#elif event.is_action_pressed("btn_2"):
		#print("bajar 1")
		#lives_instance.health_minus(1)  # Restar 1 vida (primero doradas, luego normales)

func _on_health_update(normal: int, golden: int) -> void:
	# Validar entradas
	normal = clamp(normal, 0, 3)  # Máximo 3 corazones normales
	golden = clamp(golden, 0, 3)  # Máximo 3 corazones dorados
	
	# Distribuir puntos de vida normales
	var normal_quantities = [0, 0, 0]  # Para Heart1, Heart2, Heart3
	var normal_points = normal
	for i in range(normal_quantities.size()):
		normal_quantities[i] = min(normal_points, 1)
		normal_points -= normal_quantities[i]
	
	# Distribuir puntos de vida dorados
	var golden_quantities = [0, 0, 0]  # Para Heart4, Heart5, Heart6
	var golden_points = golden
	for i in range(golden_quantities.size()):
		golden_quantities[i] = min(golden_points, 1)
		golden_points -= golden_quantities[i]
	
	# Actualizar los corazones
	for i in range(heart_nodes.size()):
		var heart = heart_nodes[i]
		if not heart:
			continue
		
		if i in NORMAL_HEART_INDICES:
			# Configurar visibilidad para corazón normal
			var normal_index = NORMAL_HEART_INDICES.find(i)
			heart.update_health(normal_quantities[normal_index])
		elif i in GOLDEN_HEART_INDICES:
			# Configurar visibilidad para corazón dorado
			var golden_index = GOLDEN_HEART_INDICES.find(i)
			heart.update_health(golden_quantities[golden_index])
	text.text= 'Vidas: %s\nVidas doradas: %s\n'%[lives_instance.current_lives, lives_instance.golden_lives]

func _on_death() -> void:
	print("¡El jugador ha muerto!")
	# Aquí puedes agregar lógica adicional para manejar la muerte del jugador
