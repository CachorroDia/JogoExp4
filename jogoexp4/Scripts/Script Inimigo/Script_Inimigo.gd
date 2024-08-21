extends CharacterBody3D
class_name Inimigo

var speed = 2
var acel = 10

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# Define o destino
	nav.target_position = Vector3(0,0,0)
func _physics_process(delta):
	var direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * speed * delta)
