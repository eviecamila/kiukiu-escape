extends Node
# ItemData.gd
class_name ItemData

var nombre: String = "Objeto"
var tool: bool = false
var frame:int = 23
var instance
func _init(instance, nombre: String = "Objeto", tool: bool = false, frame:int= 23):
	self.nombre = nombre
	self.tool = tool
	self.frame = frame
	self.instance = instance
