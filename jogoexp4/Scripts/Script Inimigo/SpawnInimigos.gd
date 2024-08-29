extends Node3D

func _ready() -> void:
	pass
	
var contagem: int = 0

func _on_timer_timeout() -> void:
	var random = RandomNumberGenerator.new() # Tem os numeros randomicos
	var cenaInimigo = load("res://Cenas/CenaInimigo.tscn") # Carrega a cena
	
	# Spawna o mob pela cena principal.
	if contagem < 10:
		for i in range(0,10):
			var inimigo = cenaInimigo.instantiate()
			var x = random.randf_range(-30, 30)
			var z = random.randf_range(-30, 30)
			inimigo.global_position = Vector3(x,1,z)
			add_child(inimigo)
			contagem += 1
	pass # Replace with function body.
