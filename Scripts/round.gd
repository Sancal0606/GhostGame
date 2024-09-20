extends Node

enum enum_enemy {Standard, Shotgun, Sniper}
@export var first_round  : Array[enum_enemy]
var normal
var sniper
var shotgun

func begin_round(enemyNormal_scene, enemySniper_scene, enemyShotgun_scene):
	self.normal = enemyNormal_scene
	self.sniper = enemySniper_scene
	self.shotgun = enemyShotgun_scene
	
func create_enemy(pos, type):
	var enemy = type.instantiate()
	enemy.initialize($"..".current_target,pos)
	$"..".add_child(enemy)
	$"..".add_enemy(enemy)


func _on_timer_timeout():
	var randomPos 
	var temp
	for enemy in first_round:
		randomPos = Vector3(randf_range(-30.0, 30-0),0,randf_range(-30.0, 30-0))
		match enemy:
			enum_enemy.Standard:
				create_enemy(randomPos,normal)
			enum_enemy.Sniper:
				create_enemy(randomPos,sniper)
			enum_enemy.Shotgun:
				create_enemy(randomPos,shotgun)
	$"..".waiting_round = false
