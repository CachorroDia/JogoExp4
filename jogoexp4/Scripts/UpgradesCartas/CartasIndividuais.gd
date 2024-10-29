extends TextureButton
class_name CartasUpgrade

func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"scale", Vector2(1.05, 1.05), 0.1)
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self,"scale", Vector2(1.0, 1.0), 0.1)
	pass # Replace with function body.
