extends Control

#这是开始菜单的脚本
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:#开始按钮
	get_tree().change_scene_to_file("res://Scenes/fight_test.tscn")
	pass # Replace with function body.


func _on_options_pressed() -> void:#菜单按钮
	get_tree().change_scene_to_file("res://Scenes/Settings_menu.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:#退出按钮
	get_tree().quit()
	pass # Replace with function body.
