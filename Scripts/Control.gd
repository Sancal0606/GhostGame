extends Control
var simultaneous_scene = load("res://Scenes/game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.time_scale = 1
	$"../monkey_prueba/AnimationTree"["parameters/Movement/blend_amount"]
	print("H")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_btn_start_pressed():
	print("hshss")
	get_tree().change_scene_to_packed(simultaneous_scene)
