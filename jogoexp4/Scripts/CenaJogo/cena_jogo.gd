extends Node3D
class_name CenaJogo

var nInimigos : int = 2
var nInimigosMortos : int = 0
var nWave : int = 0

var sorteio : int
@export var auxiliarAumentarVida : float

@onready var cenaInimigo : = preload("res://Cenas/InimigoCena.tscn")
@onready var upgradesCartas : = preload("res://Cenas/Upgrades.tscn")

@export var inimigo : InimigoClass
@export var jogador : Player

#----------- array para guardar os upgrades na tela --------#
var listaUpgrades : Array
var upgradeEscolhido : int
var icon : CompressedTexture2D = preload("res://icon.svg")
#------------------------------------------------------------

@export_group("Range para o random")
@export var randomXMin : int
@export var randomXMax : int
@export var randomZMin : int
@export var randomZMax : int

@export_group("Status do inimigo")
var vidaExtra : float = 0
var danoExtra : float = 0
var salvarVida : float = 20
var salvarDano : float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gerar_inimigos()
	jogador.contagem_inimigo.max_value = nInimigos
	pass # Replace with function body.

func atualizarContagem() -> void:
	nInimigosMortos += 1
	if (nInimigos == nInimigosMortos):
		gerar_upgrades()
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(jogador.contagem_inimigo, "value", nInimigosMortos, 0.3)
	pass

func gerar_inimigos() -> void:
	nInimigosMortos = 0
	for i in range(nInimigos):
		var instanciaInimigo : InimigoClass = cenaInimigo.instantiate() as InimigoClass
		instanciaInimigo.vidaMax = salvarVida
		instanciaInimigo.danoInimigo = salvarDano
		add_child(instanciaInimigo)
		instanciaInimigo.global_position = Vector3( randi_range(randomXMin, randomXMax), 0, randi_range(randomZMin, randomZMax))
		instanciaInimigo.inimigoMorreu.connect( atualizarContagem )
	pass

func comecar_wave() -> void:
	nInimigosMortos = 0
	sorteio = randi_range(0, 2)
	if (sorteio == 0):
		vidaExtra += 1
		salvarVida += salvarVida * (vidaExtra * 0.1)
	elif (sorteio == 1):
		danoExtra += 1
		salvarDano += salvarDano * (danoExtra * 0.1)
	elif (sorteio == 2):
		nInimigos += 1
	jogador.contagem_inimigo.max_value = nInimigos
	jogador.contagem_inimigo.value = 0
	gerar_inimigos()
	pass

func upgrade() -> void:
	if( (upgradeEscolhido == 0) and (jogador.TiroIntervalo > 0.3) ) :
		jogador.TiroIntervalo -= jogador.TiroIntervalo * 0.1
		print("velocidade ataque")
	elif(upgradeEscolhido == 1):
		jogador.danoTiro += jogador.danoTiro * 0.1
		print("dano")
	elif(upgradeEscolhido == 2):
		jogador.velMax += jogador.velMax * 0.15
		print("velocidade")
	elif(upgradeEscolhido == 3):
		jogador.vidaMax += jogador.vidaMax * 0.1
		auxiliarAumentarVida = jogador.vidaMax - jogador.barraVida.max_value
		jogador.barraVida.max_value = jogador.vidaMax
		jogador.barraVida.value += auxiliarAumentarVida
		print("vida")
	elif(upgradeEscolhido == 4 and jogador.tempoRespawn.wait_time > 0.3):
		jogador.tempoRespawn.wait_time -= jogador.tempoRespawn.wait_time * 0.1
		print("respawn")
	elif(upgradeEscolhido == 5):
		jogador.nTiro += 1
		print("número tiro")
	elif(upgradeEscolhido == 6):
		jogador.fatorCura += 1
	for i in range( len(listaUpgrades) ):
		listaUpgrades[i].queue_free()
	listaUpgrades.clear()
	comecar_wave()
	pass

func gerar_upgrades() -> void:
	var repetiu = []
	var descricoes = ["Aumenta a velocidade de ataque em 10%", "Aumenta o dano em 5%",
	"Aumenta a velocidade de movimento em 15%", "Aumenta a vida máxima em 10%", "Reduz o tempo de respawn em 10%",
	"Incrementa o número de balas por tiro", "Recebe +1 de cura por segundo"]
	for i in range(3):
		sorteio = randi_range(0, 6)
		while (sorteio in repetiu or (sorteio == 0 and jogador.TiroIntervalo < 0.3) or (sorteio == 4 and jogador.tempoRespawn.wait_time < 0.3) ) : sorteio = randi_range(0, 5)
		repetiu.append(sorteio)

		var Upgrade : UpgradeCartas = upgradesCartas.instantiate()
		jogador.tabulacaoUpgrade.add_child(Upgrade)
		Upgrade.descricao.text = descricoes[sorteio]
		Upgrade.valor = sorteio
		Upgrade.controle = get_tree().get_first_node_in_group(&"GrupoControlador")
		Upgrade.texture.texture = icon
		listaUpgrades.append(Upgrade)
		Upgrade.escolheu.connect(upgrade)
	pass
