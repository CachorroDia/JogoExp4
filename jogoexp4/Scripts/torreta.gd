extends CharacterBody3D
class_name  TorretaClass

@export var player : Player
@onready var alvo : Array[CharacterBody3D]
@export var timerTiro : Timer
@onready var balaInstance : PackedScene = preload("res://Cenas/Balas/BalaPadrao.tscn")
var torreta_posicionado : bool = false
@onready var malha : MeshInstance3D = $MeshInstance3D
@onready var animation : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("JogadorGrupo")
	$SubViewport/VidaTorreta.max_value = vidaTurrent_max
	combateTurret()
	
func _process(_delta: float) -> void:
	 # Aqui faz a torreta olhar pro inimigo que entrar na area 3d
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
		#print("A lista: ", len(alvo))

func _on_area_tiro_body_exited(body: CharacterBody3D) -> void:
	if body is InimigoClass:
		alvo.pop_at(alvo.find(body,0))
		#print("A lista: ", len(alvo))

#----------- Vida Turrent -----------#
var vidaTurrent_max : float = 30
var vidaTurrent_atual : float = vidaTurrent_max

func receberDano(dano: float):
	vidaTurrent_atual -= dano
	print("HP: ", vidaTurrent_atual, "/", vidaTurrent_max)
	if vidaTurrent_atual <= 0:
		queue_free()

func _on_area_dano_body_entered(body: Node3D) -> void:
	if body.is_in_group("Inimigo"):
		receberDano(body.danoInimigo)
	pass # Replace with function body.
