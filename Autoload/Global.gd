# Global.gd (Autoload)

extends Node
# ... otras variables ...
# Si usas un Singleton Lives, referéncialo aquí:
#var lives: Lives = Lives.get_instance() # O el método para obtener tu Singleton Lives

var current_checkpoint_position: Vector2 = Vector2.ZERO

func respawn_player(player_node):
	# 1. Reubicar al jugador
	player_node.global_position = current_checkpoint_position
	
	# 2. Restaurar la vida completa
	#lives.reset_lives() # Llama a la función de tu Singleton Lives para resetear la vida 
	
	# 3. Llamar a la función del personaje para restaurar su estado (animación, variables)
	player_node.reset_state()
	
	print("GLOBAL: Jugador reaparecido en ", current_checkpoint_position)
