extends CharacterBody3D
class_name Jogador
##Todas as variáveis e métodos que a classe player recebe, como movimentação linear e angular

const velMax = 280 ##Define o valor da velocidade máxima
const acel = 25 ##Define a aceleração do corpo
const friccao = 500 ##Define a fricção (Atrito) do corpo
const ray_length = 2000 ## Define a distancia do raycast

@export var MeshAxis : Node3D ##Variável que recebe quais são as malhas a serem giradas
@onready var olharDir : Vector3 = global_position ##Vetor 3 que define a posição inicial do jogador e será usado para atualizar a posição ao longo das variações seguintes, sendo o ponto "antigo" e a velocidade o "novo"

var versor = Vector3.ZERO ##Cria um vetor x,y,z. ZERO faz tudo começar com valor igual a 0 em todas as posições, o nome versor foi escolhido porque este é um vetor unitário o qual servirá de referência para multiplicar a norma da velocidade

func _physics_process(delta: float) -> void: ##Chamado da física da Godot, ela quem chama a função movimento_jogador
	movimento_Jogador(delta)
	RayCasting()
	
func verificar_norma(): ##Função que define para onde o versor vai apontar, retorna um vetor normalizado
	versor.x = int(Input.is_action_pressed("AndarFrente")) - int(Input.is_action_pressed("AndarTras"))
	#O Input retorna 1 ou 0 pois o resultado é booleano, então foi convertido para um inteiro, assim
	#é possivel facilmente determinar a coordenada onde o versor deverá apontar
	versor.z = int(Input.is_action_pressed("AndarDireita")) - int(Input.is_action_pressed("AndarEsquerda"))
	return versor.normalized() #O normalized serve para tornar dois pontos (o versor inicialmente era todo 0) em um
	#vetor
	
#Se quiser que o objeto deslize, usar essa função, do contrário, usar a outra
#func movimento_Jogador(delta):
	#versor = verificar_norma()
	#
	#if versor == Vector3.ZERO: #Verifica se os botões de movimentar o personagem não estão sendo pressionados
	#	if velocity.length() > (friccao * delta): #Verifica se a velocidade ainda tem que ser parada com base no
	#		#atrito
	#		velocity -= velocity.normalized() * (friccao * delta) #Reduz a velocidade no eixo que existe velocidade
	#		#com base no fator do atrito
	#	else:
	#		velocity = Vector3.ZERO #Redefine a velocidade para 0 e assim o objeto para quando está abaixo do
	#		#atrito
	#else:
	#	velocity += (versor * acel * delta) #aumenta a velocidade usando a orientação do versor e a norma da
	#	#aceleração
	#	velocity = velocity.limit_length(velMax) #Define um valor máximo para a velocidade
	#
	#move_and_slide() #Faz o objeto deslizar sobre outro, feito para topdown e plataformers
	
func movimento_Jogador(delta): ##Função que realiza o movimento do jogador, nesse caso não há aceleração para ser mais fácil o controle do personagem
	versor = verificar_norma()
	
	if versor == Vector3.ZERO:
		velocity = Vector3.ZERO
	else:
		velocity = (versor * velMax * delta)
	
	move_and_slide()
	
func RayCasting(): ## Controla a rotação do personagem baseado na posição do mouse
	var camera = $CameraJogador
	var estadoEspaco = get_world_3d().direct_space_state
	var posicaoMouse = get_viewport().get_mouse_position()
	
	var rayOrigem = camera.project_ray_origin(posicaoMouse)
	var rayDestino = rayOrigem + camera.project_ray_normal(posicaoMouse) * ray_length
	var query = PhysicsRayQueryParameters3D.create(rayOrigem, rayDestino)
	query.collide_with_areas = true
	var intersection = estadoEspaco.intersect_ray(query)
	
	if intersection.has("position"):
		var pos = intersection.position
		MeshAxis.look_at(Vector3(pos.x, global_position.y, pos.z))
	return Vector3()
