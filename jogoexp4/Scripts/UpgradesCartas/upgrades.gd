extends Panel
class_name UpgradeCartas

signal escolheu

@export var controle : CenaJogo

@onready var texture : TextureRect = $TextureButton/TextureRect
@onready var descricao : Label = $TextureButton/MarginContainer2/Label
@onready var botao : TextureButton = $TextureButton
var valor : int

func _on_texture_button_pressed() -> void:
	controle.upgradeEscolhido = valor
	escolheu.emit()
	pass # Replace with function body.
