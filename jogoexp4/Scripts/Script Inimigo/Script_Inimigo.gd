extends CharacterBody3D
class_name Inimigo

var speed = 2
var acel = 10
var vidaMax = 100
@onready var vida : float = vidaMax
var podeTomarDano = true ## Se ligado o personagem toma dano
var janelaTempo = 1.0 ## Tempo em seg para tomar outro dano

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _ready():
	
	nav.target_position = Vector3(0,0,0) ## Define o destino
	

func _physics_process(delta):
	var direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * speed * delta)
	
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
			break

func _on_barra_vida_sem_hp_restando() -> void:
	queue_free()
