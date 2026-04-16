extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:#返回按钮
	get_tree().change_scene_to_file("res://Scenes/Meun.tscn")
	pass # Replace with function body.
