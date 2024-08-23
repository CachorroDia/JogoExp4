extends Sprite3D
signal sem_hp_restando

@export var vidaMax : float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = vidaMax
	$SubViewport/Panel/ProgressBar.value = vidaMax
func tomarDano(dano: float):
	$SubViewport/Panel/ProgressBar.value -= dano
	
	if $SubViewport/Panel/ProgressBar.value <= 0.1:
		sem_hp_restando.emit()
