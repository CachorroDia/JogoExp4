extends Panel
class_name UpgradeCartas

signal escolheu

@export var controle : CenaJogo

@onready var texture : TextureRect = $Button/TextureRect
@onready var descricao : Label = $Button/MarginContainer2/Label
var valor : int

func _on_button_pressed() -> void:
	controle.upgradeEscolhido = valor
	escolheu.emit()
	pass # Replace with function body.
