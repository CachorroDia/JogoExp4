extends CanvasLayer
func _ready() -> void:
	get_node("Player_GUI").hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		get_node("Player_GUI").visible = get_tree().paused
	
func _on_bt_upgrade_1_pressed() -> void:
	print("Escolheu o upgrade 1")

func _on_bt_upgrade_2_pressed() -> void:
	print("Escolheu o upgrade 2")
	pass # Replace with function body.


func _on_bt_upgrade_3_pressed() -> void:
	print("Escolheu o upgrade 3")
	pass # Replace with function body.
