extends CharacterBody3D
class_name Inimigo

@export var speed : int
@export var vidaMax : float
@onready var vida : float = vidaMax # Vida atual do personagem
var podeTomarDano = true ## Se ligado o personagem toma dano
var janelaTempo = 1.0 ## Tempo em seg para tomar outro dano

@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D

func _ready():
	
	#var alvo := Vector3(0,0,0) ## Define o destino
	#navigation_agent_3d.set_target_position(Vector3(0,0,0))
	navigation_agent_3d.target_position = Vector3(0,1,0)
	pass

func _physics_process(delta):
	var destino = navigation_agent_3d.get_next_path_position()
	var local_destino = destino - global_position 
	local_destino = local_destino.normalized()
	velocity = local_destino * speed
	
	var temColissao = move_and_slide()
	if temColissao and podeTomarDano:
		for i in range(get_slide_collision_count()):
			if get_slide_collision(i).get_collider() is RigidBody3D:
				vida -= 50
				print(vida)
				$BarraVida.tomarDano(50.0)
				podeTomarDano = false
				await  get_tree().create_timer(janelaTempo).timeout
				podeTomarDano = true
				
func _on_barra_vida_sem_hp_restando() -> void:
	queue_free()
