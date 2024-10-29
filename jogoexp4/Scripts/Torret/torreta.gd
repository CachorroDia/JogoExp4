extends CharacterBody3D
class_name  TorretaClass

@export var player : Player
@onready var alvo : Array[CharacterBody3D]
@export var timerTiro : Timer
@onready var balaInstance : PackedScene = preload("res://Cenas/Balas/BalaPadrao.tscn")
var torreta_posicionado : bool = false
@onready var malha : MeshInstance3D = $MeshInstance3D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var barraVida : ProgressBar = $SubViewport/VidaTorreta
@onready var animacao : AnimationPlayer = $AnimationPlayer
var vidaTurrent_max : float
var vidaTurrent_atual : float
@warning_ignore("unused_signal")
signal posicionado

func _ready() -> void:
	player = get_tree().get_first_node_in_group("JogadorGrupo")
	vidaTurrent_max = player.vidaMax
	vidaTurrent_atual  = vidaTurrent_max
	barraVida.max_value = vidaTurrent_max
	barraVida.value = vidaTurrent_atual

func _input(event: InputEvent) -> void:
	if(event.is_action("Click") and !torreta_posicionado):
		torreta_posicionado = true;
		animacao.play("Colocar")
		emit_signal("posicionado")
		combateTurret()
	
func _process(_delta: float) -> void:
	 # Aqui faz a torreta olhar pro inimigo que entrar na area 3d
	if(!torreta_posicionado):
		position = Vector3(player.rayCastExport.x, 0, player.rayCastExport.z)
	if len(alvo) > 0:
		look_at(Vector3(alvo[0].position.x, global_position.y, alvo[0].position.z))

func combateTurret():
	if torreta_posicionado == true:
		timerTiro.wait_time = player.TiroIntervalo
		timerTiro.start()
		await timerTiro.timeout
		atirarTurret()
		combateTurret() # Aqui faz um looping?
	

func atirarTurret():
	if len(alvo) > 0:
		for i in range(player.nTiro):
			if len(alvo) > 0:
				# Aqui instancia a cena da bala usando a classe BalaEntity
				var balaInstancia = balaInstance.instantiate() as BalaEntity
				add_sibling(balaInstancia)
				balaInstancia.global_position = global_position # A bala parte de onde tá a turret
				balaInstancia.direcao = ( ( alvo[0].global_position * Vector3(1,0,1) - 
				( global_position * Vector3( 1,0,1 ) ) ) ).normalized() # A turret vai mirar no inimigo
				await get_tree().create_timer(0.05).timeout
	pass
	

func _on_area_tiro_body_entered(body: CharacterBody3D) -> void:
	if body is InimigoClass:
		alvo.append(body)

func _on_area_tiro_body_exited(body: CharacterBody3D) -> void:
	if body is InimigoClass:
		alvo.pop_at(alvo.find(body,0))

#----------- Vida Turrent -----------#
func receberDano(dano: float):
	var tween = get_tree().create_tween().set_parallel()
	vidaTurrent_atual -= dano
	tween.tween_property(barraVida, "value", vidaTurrent_atual, 0.5)
	if vidaTurrent_atual <= 0:
		queue_free()

func _on_area_dano_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Inimigo") and $TimerDano.is_stopped()):
		receberDano(body.danoInimigo)
		$TimerDano.start()
	pass # Replace with function body.


func _on_timer_dano_timeout() -> void:
	for body in $AreaDano.get_overlapping_bodies():
		if body is InimigoClass:
			$TimerDano.start()
			receberDano(body.danoInimigo)
	pass # Replace with function body.
