extends Node2D

@onready var eyes = $items/eyes
@onready var golden_eggs = $items/golden_eggs
@onready var ground:TileMap = $Ground
@onready var startpos = $StartPos

var width = Meta.screen_width
var height = Meta.screen_height



signal grab_started
signal completed
signal animation(function)

func _ready():
	for item in $items.get_children():
		print(item.get_child(0))
	setup_eyes()

func setup_eyes():
	# Inicializa el contador de ojos totales
	PlayerData.current_eyes_to_get = eyes.get_children().size()
	PlayerData.current_eyes_remaining = eyes.get_children().size()
	for eye in eyes.get_children():
		if not eye.visible:
			PlayerData.current_eyes_remaining-=1
			PlayerData.current_eyes_to_get-=1
			continue
		eye.connect("got", Callable(_on_eye_found))  # Conecta la señal de recolección
	update_eyes_text()
		
	#print("Faltan %d ojos" % [PlayerData.current_eyes_remaining])
func update_eyes_text():
	for eye in eyes.get_children():
		eye.update_text()
func _on_eye_found():
	# Reduce el contador de ojos restantes
	PlayerData.current_eyes_remaining -= 1
	#print("Ojo recogido. Faltan %d ojos" % [PlayerData.current_eyes_remaining])
	update_eyes_text()
	# Opcional: Verifica si se completó el nivel
	if PlayerData.current_eyes_remaining <= 0:
		emit_signal("animation", Callable(on_eyes_collected))
	if PlayerData.current_eyes_remaining == 2:
		emit_signal("animation", Callable(on_2_eyes_remaining))
func _input(e):
	if not PlayerData.debug: return
	if e.is_action_pressed("btn_4"):
		emit_signal("animation", Callable(on_eyes_collected))
	if e.is_action_pressed("btn_3"):
		emit_signal("animation", Callable(on_2_eyes_remaining))
func set_pos(now, color):
	var cam = get_node(Meta.GAME_PATH+'/Camera')
	var bg = get_node(Meta.GAME_PATH+'/BG')
	bg.color = color
	if cam.position!=now:
		cam.position = now
		bg.position = now

func destroy_blocks(start: Vector2, q: int, direction: String, source:int=-1):
	# Cargar y reproducir el efecto de sonido inicial
	$SFX.stream = load("res://assets/audio/typing/1.wav")
	# Convertir las coordenadas iniciales a enteros
	var s_x = int(start.x)
	var s_y = int(start.y)
	
	# Iterar según la cantidad de bloques a destruir
	for i in range(q):
		# Reproducir el sonido
		$SFX.play()
		
		# Calcular las coordenadas del bloque a destruir según la dirección
		var target_x = s_x
		var target_y = s_y
		
		match direction:
			"u":
				target_y -= i  # Mover hacia arriba
			"d":
				target_y += i  # Mover hacia abajo
			"l":
				target_x -= i  # Mover hacia la izquierda
			"r":
				target_x += i  # Mover hacia la derecha
		
		# Verificar límites antes de destruir el bloque
		ground.set_cell(0, Vector2i(target_x, target_y), source, Vector2i(4, 0))
		
		# Esperar un breve período antes de continuar
		await get_tree().create_timer(0.14).timeout
	
	# Cargar y reproducir el efecto de sonido final
	$SFX.stream = load("res://assets/audio/typing/2.wav")
	$SFX.play()
func on_eyes_collected(x, y, color):
	await animate(Vector2(width*x,height*y), Vector2(width*2,height*3),Vector2i(93, 66), 12,'u', color, "FFD700")
func on_2_eyes_remaining(x, y, color):
	await animate(Vector2(width*x,height*y),Vector2(120,0),Vector2i(31, 9), 10, 'u', color, "87CEEB")
	await animate(Vector2(width*x,height*y),Vector2(width*2.2,800),Vector2i(94, 33), 7, 'r', color, "000099")
	
	
func animate(prev_pos, pos, start:Vector2, q:int, direction:String="u", prev_color = "000000",color:String = "000000"):
	# switch to new position
	
	set_pos(pos, color)
	# Animation
	await get_tree().create_timer(.5).timeout
	await destroy_blocks(start, q, direction)
	await get_tree().create_timer(1).timeout
	
	# switch to prev position
	set_pos(prev_pos, prev_color)
	
#func animate(x, y):
	#var prev_pos = Vector2(width*x, height*y)
	#var pos = Vector2(width*2, height*3)
	#if prev_pos !=pos: set_pos(camera,bg,pos)
	#await get_tree().create_timer(1).timeout
	#destroy_blocks(93, 67,54,-1)
	#await get_tree().create_timer(1).timeout
	#if prev_pos !=pos: set_pos(camera,bg,prev_pos)
func _on_goal() -> void:
	emit_signal("completed")


var stage_data = { 
# 	x	y
	0: {
		#0,0,29,15
		0: {
			"bg": "87CEEB",
			"npc_list": [
				{
					"dialog": "Hola paisana; soy Pablito el gallo!;Me gustan las gallinas ekisde.;
Bueno, veo que eres\nnueva por aqui;Tienes que agarrar los\nojos de gatita;Esos gatos como los odio;Lo bueno que al morir\ndejan sus ojos",
					"location": [27, 2.5],
					"type": "hen2"
				}
			], 
			"portals":[
				 #teleporter: 0,0,3,12
				{"x":10, "y":15, "w":2, "h": 2, "to":{"room":[-2,1],"cc":[29, 15]}}
			]
		},
		#0,1,29,15
		1:{
			"bg": "FFD700",  
			"npc_list": [
				{
					"dialog": "Te felicito por llegar aqui;pero si no has agarrado el ojo;Baja por el!!!",
					"location": [23.5, 14.5], 
					"type": "hen2" 
				}
			],
			"bgm": "boss1.mp3",
			"portals":[
				{"x":29, "y":4, "w":1.8, "h": 1.8, "to":{"room":[-1,0],"cc":[3, 15]}}
			]
		},
		# 0,2,29,15
		2:{
			"bg":"000044"
		},
		
	},
	
	-1: {
		0: {
			"bg": "5555ff",
			"npc_list": [
				{
					"dialog": "Hola papu;Ten mucho cuidado;El granjero anda suelto caramba.",
					"location": [3, 2.5],
					"type": "hen"
				},
				{
					"dialog": "Existen puertas que tienen ciertos requerimientos;como por ejemplo:\ntener cierta cantidad de saltos;Ve derecho a la izquerda;y encontraras\nlas superbotas;Estas te daran un salto\nextra...\nvalida para emergencias",
					"location": [29, 2.5],
					"type": "hen"
				}
			],
			"portals":[
				{"x":6, "y":15, "w":2, "h": 2, "to":{"room":[-1,1],"cc":[3, 15]},
				"req":{"jumps":1}
				}
			]
		},
		# -1,1,18,9
		1: {
			"bg": "FFD700",  
			"npc_list": [
				{
					"dialog": "Para escapar de aqui;tienes que irte por\nlos bloques de arriba;digo...\nkiukiukiu *>",
					"location": [16, 9.5], 
					"type": "hen" 
				},
				{
					"dialog": "Malditas gallinas;Odio que anden afuera de\nsus jaulas al chile;Prefiero renunciar antes\nde estar correteandolas",
					"location": [8, 2.8], 
					"type": "farmer" 
				}
			],
			"bgm": "boss1.mp3"
			
		},
		2:{"bg":"000044"},
		3:{"bg":"ab804b"}
	},
	-2: {
		1:{
			"bg": "FFD700",  
			"bgm": "boss1.mp3",
		},
		2:{"bg":"87ceff"},
		3:{"bg":"ab804b"}},
	#aqui w
	-3: {
		1:{
#			-3,1,6,15
			"portals":[
				{"x":5, "y":15, "w":2, "h": 2, "to":{"room":[0,0],"cc":[8, 15]}}
			],
			"bg": "FFD700",  
			"bgm": "boss1.mp3", 
		},
		2:{"bg":"87CEEB"}, 
		3:{"bg":"ab804b"}},
	1:{
		1:{"bg":"000099"},
		2:{"bg":"000044"},
		3:{
			"portals":[{"x":5, "y":7, "w":2, "h": 2, "to":{"room":[4,1],"cc":[8, 15]}}],
			"npc_list":[ 
				{
					"dialog": "Mira we;Si no tienes todos los ojos de gatita;No puedes pasar el nivel todavia;Asi que muy tu pedo si cruzas en vano",
					"location": [8, 10.5], 
					"type": "hen2" 
				}
			],
			"bg": "FFD700",  
			"bgm": "boss1.mp3", 
		}
	},
	2:{
		1:{"bg":"000088"}, 
		2:{"bg":"000044"},
		3:{
			"bg": "FFD700",  
			"bgm": "boss1.mp3", 
		}
	},
	3:{
		1:{"bg":"000055"},
		2:{"bg":"000044"},
		3:{
			"bg": "FFD700",  
			"bgm": "boss1.mp3", 
		}
	},
	4:{
		1:{"portals":[{"x":8, "y":15, "w":2, "h": 2, "to":{"room":[1,3],"cc":[3, 7]}}]},
		2:{
			"npc_list":[
				{
					"dialog": "Brinca yocho;Brinca como nunca!!;Arriba esta la meta;Pero si no tienes los ojos de gatita;Jamas lograras tu cometido ",
					"location": [12, 14.5], 
					"type": "hen2" 
				}
			]
		},
		3:{
			"bg": "FFD700",  
			"bgm": "boss1.mp3", 
		}
	},
	5:{
		2:{
			"npc_list":[
				{
					"dialog": "Hola paisana;Ves ese huevo dorado\nde ahi?;Pues encuentra los 3 huevos\nOcultos en el nivel;Que pasa?;Que no los encuentras?;No te preocupes;Puedes buscarlos despues.",
					"location": [3, 14.5], 
					"type": "hen2", 
					"left":true,
					
				}
			]
		}
	}
}
