extends Node3D

#variable donde se guarda la posicion del mouse desde la camara
var ray_origin = Vector3()
#variable donde guarda el final del raycast
var ray_target = Vector3()
var enemies = []
var waiting_round = false
@export var enemyNormal_scene: PackedScene
@export var enemyShotgun_scene: PackedScene
@export var enemySniper_scene: PackedScene
@export var life_icons: Array[TextureRect]
#velocidad de movimiento
var simultaneous_scene = load("res://Scenes/main_menu.tscn")
var current_target
var lookDirection = 2

enum enum_enemy {Standard, Shotgun, Sniper}

@export var rounds: Array[PackedScene]
var round_index = 1
var isPause = false
@export var ui_Game: Control
@export var ui_Pause: Control
@export var ui_GameOver: Control
@export var ui_Win: Control
var game_win = false
#var round_index = 1
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Engine.time_scale = 1.2
	var randomPos 
	var temp
	current_target = $Player
	prepare_round()
	
func prepare_round():
	waiting_round = true
	if rounds.size() <= 0:
		Win()
		return
	var current_round = rounds[0].instantiate()
	add_child(current_round)
	current_round.begin_round(enemyNormal_scene, enemySniper_scene, enemyShotgun_scene)
	rounds.remove_at(0)
	$CanvasLayer/Game/wave/wave_txt.text = str(round_index)
	round_index+=1
	
func Win():
	Engine.time_scale = 0
	ui_Pause.hide()
	ui_Game.hide()
	ui_Win.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_win = true

func _process(delta):
	if Input.is_action_just_pressed("Pause") and !game_win:
		pause_game()
	
	if !$Player.ghost:
		$Ball.position = lookDirection
		$CanvasLayer/Game/TextureProgressBar.value = current_target.timeLeft

	if enemies.size() == 0 and waiting_round == false:
		prepare_round()

func pause_game():
	isPause = !isPause
	if isPause:
		Engine.time_scale = 0
		$Ball2.hide()
		$Ball.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ui_Game.hide()
		ui_Pause.show()
	else:
		Engine.time_scale = 1.2	
		$Ball2.show()
		$Ball.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		ui_Pause.hide()
		ui_Game.show()

func _physics_process(delta):
	#guarda la ubicacion del mouse en pixeles
	var mouse_position = get_viewport().get_mouse_position()
	
	#guarda la posiciones iniciales y finales del raycast
	ray_origin = $Pivot/Camera3D.project_ray_origin(mouse_position)
	ray_target = ray_origin + $Pivot/Camera3D.project_ray_normal(mouse_position) * 2000
	
	#prepara el raycast
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_origin
	ray_query.to = ray_target
	ray_query.collide_with_areas = true
	
	#dispara el raycast
	var raycast_result = space_state.intersect_ray(ray_query)
	
	#revisa hits del raycast
	if not raycast_result.is_empty():
		var pos = raycast_result.position
		#Consigue el vector de direccion entre el mouse y el jugador
		
		lookDirection = pos
		
		
func add_enemy(_enemy):
	enemies.append(_enemy)
	
func destroy_enemy(enemy):
	enemies.erase(enemy)
	
func show_life(life, maxlife):
	for i in maxlife:
		life_icons[i].hide()
	for i in life:
		life_icons[i].show()

	
	
func change_target_enemies(target):
	current_target = target
	for enemy in enemies:
		enemy.change_target(target)
	
func returnTarget(pos):
	$Player.returnPossesion(pos)
	for enemy in enemies:
		enemy.change_target($Player)
		
func game_over():
	ui_GameOver.show()
	ui_Game.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0
	
func _on_btn_continue_pressed():
	pause_game()


func _on_btn_try_pressed():
	
	get_tree().reload_current_scene()

func _on_btn_pause_menu_pressed():
	get_tree().change_scene_to_packed(simultaneous_scene)


func _on_btn_game_menu_pressed():
	get_tree().change_scene_to_packed(simultaneous_scene)

func _on_btn_menu_pressed():
	get_tree().change_scene_to_packed(simultaneous_scene)
