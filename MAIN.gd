extends Node
var a : int = 1
var b :int = 2
var c : String = "3"
var d : int = 0
func _enter_tree() -> void:
	c = String.num_int64(b)
	print(c+"333")
	pass
