extends CharacterBody3D
class_name Player
##Todas as variáveis e métodos que a classe player recebe, como movimentação linear e angular

var velMax = 280 ##Define o valor da velocidade máxima
const acel = 25 ##Define a aceleração do corpo
const friccao = 500 ##Define a fricção (Atrito) do corpo

#--------- variáveis para o jogador tomar/causar dano -----------#
var vidaMax : int = 100 ##Vida máxima do jogador
var vidaAtual : float = vidaMax ##A vida atual que o jogador tem
@export var OutroHit : Timer ##Define o timer para quando o jogador tomará dano novamente
@export var area : Area3D ##Define a área3d do jogador
@export var barraVida : ProgressBar ##Define a barra de progresso que mostra o HP do jogador
@export var danoTiro : float ##A quantidade de dano que o jogador causa em um tiro

#------ variáveis para o raycast -------#
@onready var camera = $Camera3D ##Determina qual será o nó da câmera que fará o screen ray-cast
@export_flags_3d_physics var raycastMask : int ##Define quais camados o raycast irá analizar
var raioOrigem = Vector3() ##Define a origem de onde o raio irá ser gerado, de modo a apontar onde o mouse estará
var raioFim = Vector3() ##Define onde o raio termina, gerando assim o vetor

# ------------------------------------ #
@export var MeshAxis : Node3D ## Variável que recebe quais são as malhas a serem giradas
@onready var olharDir : Vector3 = global_position ## Vetor 3 que define a posição inicial do jogador e será usado para atualizar a posição ao longo das variações seguintes, sendo o ponto "antigo" e a velocidade o "novo"
# ------------- Sistema de tiro -------#
@export_group("Combat Nodes") ## Grupo de variáveis que irão controlar o "spawn" de tiros
@export var BulletTimer : Timer ## Define o nó Timer, que irá determinar quando gerar balas
@export var BulletSpawn : Marker3D ## Instancia o marcador de posição que irá gerar as balas
@export var BulletScene : PackedScene ## Instancia a cena da bala, usada para criar com o instantiate
@export_subgroup("Parâmetros de combate") ##Sub parâmetros que irão controlar a bala
@export_range(0.02, 3.0, 0.02) var TiroIntervalo : float = 3 ## Tempo para gerar uma nova bala
var direcaoBala : Vector3 ## Vetor que irá definir qual será a trajetória da bala, será multiplicado com velocidade e delta
# -------------------------

#------------ Função para causar dano no jogador ------------- #
func _on_area_3d_body_entered(body: Node3D) -> void: ##Verifica se o inimigo entrou na área de tomar dano do jogador
	if body is InimigoClass and OutroHit.is_stopped():
		print("Tocou")
		causar_dano(10)
		OutroHit.start()
	pass # Replace with function body.
	
func _on_outro_hit_timeout() -> void: ##Usada para verificar se o inimigo continua na área e depois de algum tempo causar mais dano
	for body in area.get_overlapping_bodies():
		if body is InimigoClass:
			OutroHit.start()
			causar_dano(10)
			print("OutroDano")
	pass # Replace with function body.
	
func causar_dano(dano) -> void: ##Subtrai a vida do jogador e atualiza a barra de progresso
	vidaAtual -= dano
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(barraVida, "value", vidaAtual, 1)
	if vidaAtual < 0:
		visible = false
		esta_vivo = false
		$Area3D.set_collision_mask_value(3, false)
		$Respawn.start()
	pass
# -------------------------------------------------------------- #

#Essa função faz o modelo apontar para o movimento e não para o mouse, por isso foi descontinuado
#func animacao_giro() -> void: ##Define uma interpotalação linear de modo que o personagem oscile de da posicisão inicial dele para a nova definida pela velocidade
#	if velocity: #Se velocisade for diferente de 0
#		olharDir = lerp(olharDir, global_position + (velocity * Vector3(1,0,1)), 0.2) #Cria uma interpolação linear,
#		#começando da poseição inicial (olharDir). E vai oscilar até onde a velocidade aponta. O úiltimo termo é
#		#a variação
#		MeshAxis.look_at(olharDir) #define para onde o objeto olha

var versor = Vector3.ZERO ##Cria um vetor x,y,z. ZERO faz tudo começar com valor igual a 0 em todas as posições, o nome versor foi escolhido porque este é um vetor unitário o qual servirá de referência para multiplicar a norma da velocidade

func _ready() -> void: ## Atualmente usado para começar um loop com a função combate(), nela será feito a criação das balas. Também defini umas propriedades iniciais
	barraVida.max_value = vidaMax
	barraVida.value = vidaAtual
	regen()
	combate()

func _physics_process(delta: float) -> void: ##Chamado da física da Godot, ela quem chama a função movimento_jogador
	movimento_Jogador(delta)
	#animacao_giro()
	
	#----------- Para o ray-cast -------------:
	var estadoFisica = get_world_3d().direct_space_state ##Recebe o estado atual da física do mundo
	var mouse_position = get_viewport().get_mouse_position() ##Variável que receberá a posição do mouse de acordo com onde ele está na tela
	
	raioOrigem = camera.project_ray_origin(mouse_position) #Define a origem do raio
	raioFim = raioOrigem + camera.project_ray_normal(mouse_position) * 2000 #project_ray_normal cria uma normal em onde onde se está vendo. Cria o ponto final de onde ocorrerá o ray-cast
	var query = PhysicsRayQueryParameters3D.create(raioOrigem, raioFim, raycastMask) #Faz uma query para criar o raio (Uma fila) só para fazer o raycast
	var interseccao = estadoFisica.intersect_ray(query) #Faz o raio interagir com os objetos, gerando um dicionário, contendo o id do objeto colidido, qual objeto e mais coisas
	
	if not interseccao.is_empty() : #Testa se um raio conseguiu interagir e rotaciona o player
		var pos : Vector3 = interseccao.position
		MeshAxis.look_at(Vector3(pos.x, global_position.y, pos.z), Vector3(0,1,0))
		direcaoBala = (global_position * Vector3(1,0,1) ).direction_to(pos * Vector3(1,0,1) )
# --------------------------- #
#------- Função para atirar ------- #
func combate() -> void: ##Função responsável em gerar as balas
	BulletTimer.wait_time = TiroIntervalo #Define o tempo do próximo tiro
	BulletTimer.start() #Inicia o timer
	await BulletTimer.timeout #Espera o tempo acabar
	disparar()
	combate()
	pass
	
var numero_tiros = 2
func disparar() -> void: ##Gera a bala em questão
	if esta_vivo == true:
		for i in range (numero_tiros):
			var balaInstancia : BalaEntity = BulletScene.instantiate() as BalaEntity #Instancia a bala
			add_sibling(balaInstancia) #Adiciona como irmã (para ser independente do jogador)
			balaInstancia.global_position = BulletSpawn.global_position #Define a posição da bala inicial
			balaInstancia.direcao = direcaoBala #Define a diração da velocidade da bala
			await get_tree().create_timer(0.1).timeout
	
	#---------------------------------#
	
#-------Variavel de controle do upgrade de regen-----------#
var taxa_regen : float = 1.0 # HP por segundo

func regen(): ## Regeneração de vida do player
	# Definindo timer
	var regen_timer = Timer.new()
	add_child(regen_timer)
	regen_timer.one_shot = false
	regen_timer.autostart = true
	regen_timer.wait_time = 1.0
	regen_timer.timeout.connect(func():
		
		if vidaAtual < vidaMax:
			vidaAtual += taxa_regen
			print("Regenerando! [", vidaAtual, "]" )
			barraVida.value = vidaAtual
			if vidaAtual > vidaMax:
				vidaAtual = vidaMax
		)
	regen_timer.start()
	pass
	
#-----------Configuração de respawn-----------#
var ponto_respawn = Vector3(0,1,0)
var esta_vivo = true

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
	if esta_vivo == true: 
		move_and_slide()
		
@onready var timer_respawn = $Respawn
func _on_respawn_timeout() -> void:
	visible = true
	vidaAtual = vidaMax
	esta_vivo = true
	global_position = ponto_respawn
	$Area3D.set_collision_mask_value(3, true)
	pass
