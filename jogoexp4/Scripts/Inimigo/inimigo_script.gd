extends CharacterBody3D
class_name InimigoClass
##Classe que define o comportamento dos inimigos, começa ativando o timer e ajusta a barra de vida no _ready()

var vel = 2 ##Velocidade que o corpo irá se mover

@onready var nav : NavigationAgent3D = $NavigationAgent3D ##Agente de navegação

@export var vidaMax : float ##Define a vida máxima do inimigo
@onready var vidaAtual : float = vidaMax ##Define a vida atual do inimigo

@export var area : Area3D ##Área de colisão para verificar as balas
@export var barraVida : ProgressBar ##Define a barra de progressão

@export var jogador : Player ##Instancia a classe Player
var danoJogador : float ##Instancia o dano do jogador que existe dentro da classe Player

@export var timer : Timer ##Define o timer

var direc = Vector3()

func _ready() -> void:
	jogador = get_tree().get_first_node_in_group("JogadorGrupo")
	danoJogador = jogador.danoTiro
	timer.start()
	barraVida.max_value = vidaMax
	barraVida.value = vidaAtual
	pass

func _on_area_3d_area_entered(area: Area3D) -> void: ##Quando a bala entra na área3d, reduz a vida do inimigo
	if(area.is_in_group("bala") ):
		vidaAtual -= danoJogador
		barraVida.value = vidaAtual
		if(vidaAtual <= 0):
			queue_free()
	pass # Replace with function body.
	

#func _physics_process(delta: float) -> void:
#	var direc = Vector3()
#	
#	nav.target_position = jogador.global_position
#	direc = nav.get_next_path_position() - global_position
#	direc = direc.normalized()
#	velocity = velocity.lerp(direc * vel, acel * delta)
#	
#	look_at( Vector3(jogador.global_position.x, global_position.y, jogador.global_position.z) )
#	move_and_slide()



func _on_timer_timeout() -> void: ##Chamada toda vez que o timer zera, define uma nova posição pro pathfinder
	
	nav.target_position = jogador.global_position
	direc = nav.get_next_path_position() - global_position
	direc = direc.normalized()
	velocity = direc * vel
	pass # Replace with function body.

func _process(delta: float) -> void: ##Move o personagem com a velocidade gerada toda vez que o timer zera e constantemente muda a direção que o inimigo olha
	look_at( Vector3(jogador.global_position.x, global_position.y, jogador.global_position.z) )
	move_and_slide()
