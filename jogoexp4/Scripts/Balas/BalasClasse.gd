extends Node3D
class_name BalaEntity
##Clase que dita o comportamento de cada bala individualmente

var direcao : Vector3 = Vector3.RIGHT ##Será a variável que irá armazenar a diração da bala
@export var velocidade : float = 40.0 ##Controla a velocidade a qual o projétil se movimentará
const DELETARTEMPO : float = 2.0 ##Quando será apagada da cena

@onready var Temporizador : Timer = Timer.new() ##Define uma variável que recebe um novo temporizador

@export var particle : GPUParticles3D ##Instancia uma partícula

func _ready(): ##Função chamada no começo para definir propriedades importantes da bala
	particle.set_emitting(true) #Faz o sistema de partícula ativar
	add_child(Temporizador) #Cria um nó filho que será o temporizador
	Temporizador.wait_time = DELETARTEMPO #Define o tempo de morte da bala
	Temporizador.one_shot = true #O temporizador irá disparar somente uma vez
	Temporizador.timeout.connect(deletar) #Quando o temporizador acabar sua contagem, irá executar a função deletar()
	Temporizador.start() #Faz o contador começar sua contagem

func _physics_process(delta: float) -> void: ##Chamado toda vez quando a godot irá verificar a física para tornar
	translate( (direcao * velocidade) * delta)

func deletar(): ##Função chamada para deletar a bala quando o timer é esgotado
	queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	get_tree().create_timer(0.1).timeout
	queue_free()
	pass # Replace with function body.
