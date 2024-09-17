extends Node3D

#variable donde se guarda la posicion del mouse desde la camara
var ray_origin = Vector3()
#variable donde guarda el final del raycast
var ray_target = Vector3()
var enemies = []
@export var enemyNormal_scene: PackedScene
@export var enemyShotgun_scene: PackedScene
@export var enemySniper_scene: PackedScene
#velocidad de movimiento


var lookDirection = 2

enum enum_enemy {Standard, Shotgun, Sniper}
@export var first_round  : Array[enum_enemy]
@export var second_round : Array[enum_enemy]
@export var third_round  : Array[enum_enemy]
var round = 1
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Engine.time_scale = 1.2
	var randomPos 
	var temp
	for enemy in first_round:
		randomPos = Vector3(randf_range(-30.0, 30-0),0,randf_range(-30.0, 30-0))
		match enemy:
			enum_enemy.Standard:
				create_enemy(randomPos,enemyNormal_scene)
			enum_enemy.Sniper:
				create_enemy(randomPos,enemySniper_scene)
			enum_enemy.Shotgun:
				create_enemy(randomPos,enemyShotgun_scene)
	


func _process(delta):
	if !$Player.ghost:
		$Ball.position = lookDirection
	#print(enemies.size())
	if enemies.size() <= 0:
		print(round)
		if round == 1:
			var randomPos 
			var temp
			for enemy in second_round:
				randomPos = Vector3(randf_range(-30.0, 30-0),0,randf_range(-30.0, 30-0))
				match enemy:
					enum_enemy.Standard:
						create_enemy(randomPos,enemyNormal_scene)
					enum_enemy.Sniper:
						create_enemy(randomPos,enemySniper_scene)
					enum_enemy.Shotgun:
						create_enemy(randomPos,enemyShotgun_scene)
			round+=1
		elif round == 2:
			var randomPos 
			var temp
			for enemy in third_round:
				randomPos = Vector3(randf_range(-30.0, 30-0),0,randf_range(-30.0, 30-0))
				match enemy:
					enum_enemy.Standard:
						create_enemy(randomPos,enemyNormal_scene)
					enum_enemy.Sniper:
						create_enemy(randomPos,enemySniper_scene)
					enum_enemy.Shotgun:
						create_enemy(randomPos,enemyShotgun_scene)
			round+=1

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
		
		
func create_enemy(pos,type):
	var enemy = type.instantiate()
	var prueba = $Player
	enemy.initialize(prueba,pos)
	#enemy.target = temp
	add_child(enemy)
	enemies.append(enemy)
	
func destroy_enemy(enemy):
	enemies.erase(enemy)
	
func change_target_enemies(target):
	for enemy in enemies:
		enemy.change_target(target)
	
func returnTarget(pos):
	$Player.returnPossesion(pos)
	for enemy in enemies:
		enemy.change_target($Player)
		
func game_over():
	get_tree().reload_current_scene()
	
