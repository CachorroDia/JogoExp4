extends Node3D

@export var refJogador : Player

func _ready() -> void:
	Spawn()
	pass
	
func _input(event: InputEvent) -> void:
	Upgrades()
	
func Upgrades():
	# upgrade de aumento de velocidade de movimento
	if Input.is_action_just_pressed("ui_accept"):
		refJogador.velMax += refJogador.velMax * 0.1
		print("Aumentando Velocidade: [", refJogador.velMax, "]")
	# upgrade de dano
	if Input.is_action_just_pressed("ui_accept"):
		refJogador.danoTiro += refJogador.danoTiro * 0.2
		print("Aumentando Dano: [", refJogador.danoTiro, "]")
	# upgrade de vida base
	if Input.is_action_just_pressed("ui_accept"):
		refJogador.vidaMax += refJogador.vidaMax * 0.1
		print("Aumetando Vida: [", refJogador.vidaMax, "]")
	# upgrade de velocidade de ataque
	if Input.is_action_just_pressed("ui_accept"):
		refJogador.TiroIntervalo -= refJogador.TiroIntervalo * 0.1
		print("Aumentando velocidade: [" , refJogador.TiroIntervalo, "]")
		if refJogador.TiroIntervalo < 0.2 :
			print("Num pode abaixar mais que isso!")
	# upgrade de regen de vida
		if Input.is_action_just_pressed("ui_accept"):
			var timer_upgrade = Timer.new()
			add_child(timer_upgrade)
			timer_upgrade.one_shot = true
			timer_upgrade.autostart = false
			timer_upgrade.wait_time = 1.0
			timer_upgrade.timeout.connect(func():
				if refJogador.taxa_regen < 5.0:
					refJogador.taxa_regen += 1
					print("Aumentando Regeneração: [", refJogador.taxa_regen, "]")
					refJogador.barraVida.value = refJogador.vidaAtual
				)
			timer_upgrade.start()
	# upgrade de quantidade de projeteis
		if Input.is_action_just_pressed("ui_accept"):
			refJogador.numero_tiros += 1
			print("Atirando [", refJogador.numero_tiros, "] de balas")
	# upgrade de menor tempo spawn
		if Input.is_action_just_pressed("ui_accept"):
			refJogador.timer_respawn.wait_time -= 0.5
			print("O spawn tempo é: [", refJogador.timer_respawn, "]")
	pass
	
# Controla o spawn do inimigo
var contagem: int = 0
func Spawn():
	var random = RandomNumberGenerator.new() # Tem os numeros randomicos
	var cenaInimigo = load("res://Cenas/InimigoCena.tscn") # Carrega a cena
	
	# Spawna o mob pela cena principal.
	await get_tree().create_timer(5).timeout
	if contagem < 10:
		for i in range(0,10):
			var inimigo = cenaInimigo.instantiate()
			var x = random.randf_range(-30, 30)
			var z = random.randf_range(-30, 30)
			inimigo.global_position = Vector3(x,1,z)
			add_child(inimigo)
			contagem += 1
	pass
