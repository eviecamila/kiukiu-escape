extends Node

const npc_list = {
	0:{0:[{
			"dialog": ["Soy la coco coco", "Follame, Evie!", "no te creas we, es cura"],
			"location": [1, 2],
			"type":"sign"
		}]},
	-1: {
		0: [{
			"dialog": ["Soy la coco coco", "Follame, Evie!", "no te creas we, es cura"],
			"location": [8, 2],
			"type":"sign"
		},
		{
			"dialog": ["Kiu Kiu *>"],
			"location": [0, 3]
			
		}
		]
	},
	-2: {}
}

func get_npc_list(room_x: int, room_y: int) -> Array:
	var room_key = room_x
	var subroom_key = room_y
	
	if not npc_list.has(room_x):
		return []
		
	var subrooms = npc_list[room_x]
	if not subrooms.has(room_y):
		return []
		
	return subrooms[room_y]
