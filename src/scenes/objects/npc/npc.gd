extends Node2D
class_name NPC

# Propiedades exportadas
@export var dialog_data: Array = ["No hay diálogo disponible."]  # Datos del diálogo
@export var interact_radius: int = 100  # Radio de interacción
@export var interact_action: String = "btn_1"  # Acción de entrada para iniciar el diálogo
@export var npc_scale: float = 1.5
@export var type: String = "hen"  # Tipo de NPC (por ejemplo, "hen", "sign")

# Referencias a nodos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $AnimatedSprite2D/InteractionArea
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer  # Reproductor de sonido

const player_node_path = "/root/Stage/C/SVPC/SVP/Node2/Hen"  # Ruta al nodo del jugador
const npc_dialog_path = "/root/Stage/C/SVPC/SVP/NpcDialog"  # Ruta al nodo NpcDialog
const bgm_path = "/root/Stage/BGM"  # Ruta al nodo NpcDialog
# Estado del NPC
var is_player_near: bool = false
var is_interacting: bool = false  # Indica si el NPC está interactuando
var npc_resource: NPCRes = null  # Recurso del NPC

func _ready():
	# Cargar el recurso del NPC
	var resource_path = "res://src/resources/npcs/" + type + ".tres"
	npc_resource = load(resource_path)
	npc_scale = npc_resource.scale
	if not npc_resource:
		print("Error: No se pudo cargar el recurso del NPC:", resource_path)
		return

	# Configurar el sprite animado
	animated_sprite.set_sprite_frames(npc_resource.sprite)

	# Escalar el NPC
	scale = Vector2(npc_scale, npc_scale)
	position.x += npc_resource.offset_x
	position.y += npc_resource.offset_y
	# Conectar señales
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))

	# Iniciar animación idle
	animated_sprite.play("idle")

func start_dialog():
	if not is_interacting and is_player_near:
		#Bajarle a la musica
		var bgm = get_node(bgm_path)
		bgm.set_volume_linear(.2)
		# Bloquear controles del jugador
		var player = get_node(player_node_path)
		player.cant_press()  # Desactivar acciones del jugador
		is_interacting = true
		animated_sprite.stop()  # Detener animación idle

		# Reproducir sonido de inicio del NPC
		if npc_resource.sfx_1:
			audio_player.stream = npc_resource.sfx_1
			audio_player.play()
		# Mostrar el diálogo
		var npc_dialog = get_node(npc_dialog_path)  # Obtener el nodo NpcDialog
		npc_dialog.dialog(self)  # Iniciar el diálogo
		npc_dialog.visible = true  # Hacer visible el diálogo

func end_dialog():
	var bgm = get_node(bgm_path)
	bgm.set_volume_linear(1)
	# Reactivar controles del jugador después de 1 segundo
	var player = get_node(player_node_path)
	player.set_physics_process(true)
	player.can_press("btn_1")
	# Reproducir sonido de finalización del NPC
	if npc_resource.sfx_2:
		audio_player.stream = npc_resource.sfx_2
		audio_player.play()

	# Reiniciar estado del NPC
	is_interacting = false

func _on_body_entered(body: Node2D):
	if "Hen" in body.to_string():  # Verificar si el cuerpo entrante es el jugador
		is_player_near = true
		body.can_press(interact_action)  # Habilitar indicador de interacción
		body.can_throw = false
		print("Jugador dentro del área de interacción.")

func _on_body_exited(body: Node2D):
	if "Hen" in body.to_string():
		is_player_near = false
		body.cant_press()  # Deshabilitar indicador de interacción
		body.can_throw = true
		print("Jugador fuera del área de interacción.")

func _input(event):
	if is_player_near and Input.is_action_just_pressed(interact_action) and not is_interacting:
		start_dialog()
