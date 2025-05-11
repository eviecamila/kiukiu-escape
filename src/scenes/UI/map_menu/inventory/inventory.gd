extends Node
class_name Inventory

signal item_used
signal equip
# Variables para almacenar herramientas e inventario
var inventory = []
var tools = []
var nombre = ""

var equipped_items = [null, null]

# Variable estática para almacenar la única instancia del Singleton
static var instance = null


#var item_data = ItemData.new("nombrepene", true, 2)
# Constructor privado para evitar instancias adicionales
func _init() -> void:
	if instance != null:
		printerr("Error: Inventory ya ha sido inicializado.")
		return
	inventory = []
	tools = []
	nombre = "la mayatiza"
	instance = self
	print("Inventory inicializado.")

# Método estático para acceder a la instancia del Singleton
static func get_instance() -> Inventory:
	if instance == null:
		instance = Inventory.new()
	return instance

func get_equipped_objects():
	var item_1 = equipped_items[0]
	var item_2 = equipped_items[1]
	if item_1: 
		if item_1["is_tool"]:
			item_1 = tools[item_1["position"]]
		else:
			item_1 = inventory[item_1["position"]]
	if item_2: 
		if item_2["is_tool"]:
			item_2 = tools[item_2["position"]]
		else:
			item_2 = inventory[item_2["position"]]
	return [item_1, item_2]
		
# Obtener el inventario o las herramientas
func get_inventory(t: bool = true) -> Array:
	if t:
		print("Herramientas:", tools)
		return tools
	else:
		print("Inventario:", inventory)
		return inventory
		
		
func equip_item(i, pos:int = 0, t: bool = true):
	#no hay items
	if tools.size() == 0 and inventory.size() == 0:return
	
	var item
	var other_pos = null
	match pos:
		1: other_pos = 0
		0: other_pos = 1
		
		
	if t: item = tools[i]
	else: item = inventory[i]
	
	if not item: return
	
	var _item ={
		"position":i,
		"is_tool":t
	}
	if _item == equipped_items[pos]: return
	if not equipped_items[other_pos] or equipped_items[other_pos]==_item:
		equipped_items[other_pos]=equipped_items[pos]
		
	equipped_items[pos] = _item
	# es distinto



#Funcion para usar los objetos
func use_item(pos, hen):
	var items
	if not equipped_items[pos]: return
	if equipped_items[pos]['is_tool']:items = tools
	else : items  = inventory
	var posicion = equipped_items[pos]["position"]
	var objeto = load(items[posicion].instance).instantiate()
	objeto.use(hen)
	#remover item si es un consumible
	if items == inventory:
		inventory.remove_at(posicion)
		equipped_items[pos] = null
		emit_signal("item_used", pos)
	
	
# Agregar herramientas al inventario
func add_to_inv(item: ItemData,  consumible:bool = true, position: int = 0,adding: bool = true) -> Dictionary:
	var inv = inventory if consumible else tools
	# Validar que item sea una instancia válida de InvItem
	if not item or not item is ItemData:
		return {"status": false, "msg": "El objeto no es una instancia válida de InvItem."}
	print("El item es:", item)
	
	if not adding:
		if position < inv.size():
			inv.remove_at(position)
			return {"status": true, "msg": "Objeto descartado con éxito."}
		else:
			return {"status": false, "msg": "Posición inválida para descartar."}

	if inv.size() >= 9:
		return {"status": false, "msg": "No se pueden agregar más de 9 objetos."}

	inv.append(item)  # Usar append en lugar de tools += [item]
	print(inv)
	var inv_length = inv.size()
	print(consumible)
	if !equipped_items[0]:
		equip_item(inv_length - 1, 0, !consumible)  # Cambiado aquí
	elif !equipped_items[1]:
		equip_item(inv_length - 1, 1, !consumible)  # Y aquí
	refresh()
	return {"status": true, "msg": "%s agregado con éxito" % [item.nombre]}
func refresh():
	emit_signal("equip")
# Limpiar el inventario y las herramientas
func clear_inventory() -> void:
	tools.clear()
	inventory.clear()
	print("Inventario y herramientas limpiados.")
