extends Node

var estar_chingando = not PlayerData.debug
const bg = "bg"
const bgm= "bgm"
const x = "x"
const y ="y"
const w = "w"
const h = "h"
const npc_list = { 
# 	x	y
	0: {
		0: {
			bg: "87CEEB",
			"npc_list": [
				{
					"dialog": "Hola paisana; soy Pablito el gallo!;Me gusta follar gallinas ekisde.;
Bueno, veo que eres\nnueva por aqui;Tienes que agarrar los\nojos de gatita;Pinches gatos bastardos;como los odio;
Tengo ladillas y corucos\npor andar follando gallinas",
					"location": [27, 2.5],
					"type": "hen2"
				}
			],
			"portals":[
				#portal de la caseta 2 al subterraneo
				#{x:28, y:15, w:2, h: 2, "to":{"room":[-1,1],"cc":[3, 6]}}
			]
		},
		1:{
			bg: "FFD700",  # Color de fondo para el nuevo room [-1, -1]
			"npc_list": [
				{
					"dialog": "COCO COCO! Soy una gallina kiukiu.;¿Quieres follarme Evie?",
					"location": [3, 13],  # Ubicación dentro del room [-1, -1]
					"type": "hen2"  # Tipo de NPC: gallina
				}
			],
			bgm: "boss1.mp3",
			"portals":[
				{x:29, y:4, w:1.8, h: 1.8, "to":{"room":[-1,0],"cc":[3, 15]}}
			]
		},
		2:{
			bg:"000044"
		}
	},
	
	-1: {
		0: {
			bg: "5555ff",
			"npc_list": [
				{
					"dialog": "Soy la coco coco;Follame, Evie!;no te creas we, es cura",
					"location": [8, 2],
					"type": "hen"
				},
				{
					"dialog": "Kiu Kiu *>",
					"location": [0, 3],
					"type": "hen"
				}
			],
			"portals":[
				{x:6, y:15, w:2, h: 2, "to":{"room":[-1,1],"cc":[3, 15]}}
			]
		},
		1: {
			bg: "FFD700",  # Color de fondo para el nuevo room [-1, -1]
			"npc_list": [
				{
					"dialog": ["COCO COCO! Soy una gallina feliz.;¿Quieres un huevo?"],
					"location": [3, 6],  # Ubicación dentro del room [-1, -1]
					"type": "hen"  # Tipo de NPC: gallina
				}
			],
			bgm: "boss1.mp3"
			
		},
		2:{bg:"000044"},
		3:{bg:"ab804b"}
	},
	-2: {2:{bg:"87ceff"}, 3:{bg:"ab804b"}},
	#aqui w
	-3: {2:{bg:"87CEEB"}, 3:{bg:"ab804b"}},
	1:{
		1:{bg:"000099"},
		2:{bg:"000044"}
	},
	2:{
		1:{bg:"000088"}, 
		2:{bg:"000044"}
	},
	3:{
		1:{bg:"000055"},
		2:{bg:"000044"}
	}
}

# Función para obtener el color de fondo de un room
func get_bg(room_x: int, room_y: int) -> String:
	#print("obteniendo bg de [%d, %d]"%[room_x, room_y])
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get(bg, "87CEEB")
	return "87CEEB"

func get_song(x, y):
	if not estar_chingando: return ""
	x = int(x)  # Convierte a entero
	y = int(y)  # Convierte a entero

	if npc_list.has(x):
		print("Room X encontrado:", x)
		if npc_list[x].has(y):
			print("Room Y encontrado:", y, "BGM:", npc_list[x][y].get(bgm, "overworld.mp3"))
			return npc_list[x][y].get(bgm, "overworld.mp3")
		else:
			print("No se encontró la subclave Y:", y)
	else:
		print("No se encontró la clave X:", x)
	return "overworld.mp3"

# Función para obtener la lista de NPCs de un room
func get_npc_list(room_x: int, room_y: int) -> Array:
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get("npc_list", [])
	return []

# Función para obtener los portales de un room
func get_portals(room_x: int, room_y: int) -> Array:
	if npc_list.has(room_x) and npc_list[room_x].has(room_y):
		return npc_list[room_x][room_y].get("portals", [])
	return []
