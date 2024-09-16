extends CharacterBody3D

var min_speed = 12
var max_speed = 16
@export var posseses_enemy: PackedScene
@export var bullet: PackedScene
@export var life = 3
@export var minTimeShoot = 1.5
@export var maxTimeShoot = 2.5
var rotationSpeed = 10
@export var maxRange = 60
var speed
var target
var dirNor
var additional_forces = Vector3(0,0,0)
@export var damage_force = 10

#Materiales
@export var DAMAGE_MAT = preload("res://Materials/damage.tres")
@export var ENEMY_MAT = preload("res://Materials/soldier.tres")

func _physics_process(delta):
	if  is_instance_valid(target):  
		var dir = target.position - position
		dirNor = dir.normalized()
		dirNor.y = 0
		if dir.length() > maxRange:
			velocity = dirNor * speed
		else:
			velocity = Vector3.ZERO
		var dir2d = Vector2(dir.z,dir.x)
		$Pivot.rotation.y = lerp_angle($Pivot.rotation.y,dir2d.angle(),delta * rotationSpeed)
	velocity += additional_forces
	move_and_slide()
	
func initialize(player, initPosition):
	target = player
	position = initPosition
	$Pivot/BulletPoint/Timer.wait_time = randf_range(minTimeShoot,maxTimeShoot)
	speed = randi_range(min_speed,max_speed)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
func posses():
	var possesTemp = posseses_enemy.instantiate()
	
	possesTemp.position = position
	possesTemp.initialize()
	target.hide()
	$"..".add_child(possesTemp)
	$"..".enemies.erase(self)
	$"..".change_target_enemies(possesTemp)
	queue_free()
	
func change_target(newTarget):
	target = newTarget
	
func take_damage(_damage, _dir):
	life -= _damage
	print("H")
	$Pivot/Enemy/Armature/Skeleton3D/Mesh.set_surface_override_material(0,DAMAGE_MAT)
	additional_forces = _dir * damage_force
	$Damage_Timer.start()
	$Damage_Color_Timer.start()
	if life <= 0:
		die()

func die():
	$"..".destroy_enemy(self)
	queue_free()

func _on_timer_timeout():
	var bulletTemp = bullet.instantiate()
	bulletTemp.global_transform = $Pivot/BulletPoint.global_transform
	var dirTemp = target.position - $Pivot/BulletPoint.global_position
	dirTemp.y = 0
	dirTemp = dirTemp.normalized()
	bulletTemp._initialize(dirTemp)
	$Pivot/Flash/AnimationPlayer.play("slash")
	$"..".add_child(bulletTemp)


func _on_damage_timer_timeout():
	additional_forces = Vector3.ZERO
	
func _on_damage_color_timer_timeout():
	$Pivot/Enemy/Armature/Skeleton3D/Mesh.set_surface_override_material(0,ENEMY_MAT)
