extends CharacterBody3D

var min_speed = 12
var max_speed = 16
@export var posseses_enemy: PackedScene
@export var bullet: PackedScene
@export var life = 3
@export var angleDelta = 5
var rotationSpeed = 10
var maxRange = 30
var speed
var target
var dirNor
var additional_forces = Vector3(0,0,0)
@export var damage_force = 10

#Materiales
@export var DAMAGE_MAT = preload("res://Materials/damage.tres")
@export var ENEMY_MAT = preload("res://Materials/soldier_shotgun.tres")

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
	$Pivot/BulletPoint/Timer.wait_time = randf_range(1.5,2.5)
	speed = randi_range(min_speed,max_speed)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
func posses():
	var possesTemp = posseses_enemy.instantiate()
	
	possesTemp.position = position
	possesTemp.initialize()
	target.hide()
	target.position = Vector3(100,100,100)
	$"..".add_child(possesTemp)
	$"..".enemies.erase(self)
	$"..".change_target_enemies(possesTemp)
	queue_free()
	
func change_target(newTarget):
	target = newTarget
	
func take_damage(_damage,_dir):
	life -= _damage
	additional_forces = _dir * damage_force
	$Pivot/Enemy/Armature_001/Skeleton3D/Mesh.set_surface_override_material(0,DAMAGE_MAT)
	$Damage_Timer.start()
	$Damage_Color_Timer.start()
	if life <= 0:
		die()

func die():
	$"..".destroy_enemy(self)
	queue_free()

func _on_timer_timeout():
	$Pivot/Flash/AnimationPlayer.play("slash")
	#Get angles
	var dirTemp = target.position - $Pivot/BulletPoint.global_position
	dirTemp.y = 0
	dirTemp = dirTemp.normalized()
	var angleTemp = rad_to_deg(Vector2(dirTemp.x,dirTemp.z).angle())
	
	var xMax = cos(deg_to_rad(angleTemp + angleDelta))
	var yMax = sin(deg_to_rad(angleTemp + angleDelta))
	var dirMax = Vector3(xMax,0,yMax).normalized()
	
	var xMin = cos(deg_to_rad(angleTemp - angleDelta))
	var yMin = sin(deg_to_rad(angleTemp - angleDelta))
	var dirMin = Vector3(xMin,0,yMin).normalized()
	
	#Create Bullets
	var bulletTemp1 = bullet.instantiate()
	var bulletTemp2 = bullet.instantiate()
	var bulletTemp3 = bullet.instantiate()
	
	bulletTemp1.global_transform = $Pivot/BulletPoint.global_transform
	bulletTemp2.global_transform = $Pivot/BulletPoint.global_transform
	bulletTemp3.global_transform = $Pivot/BulletPoint.global_transform
	
	bulletTemp1._initialize(dirTemp)
	bulletTemp2._initialize(dirMin)
	bulletTemp3._initialize(dirMax)
	
	$"..".add_child(bulletTemp1)
	$"..".add_child(bulletTemp2)
	$"..".add_child(bulletTemp3)


func _on_damage_timer_timeout():
	additional_forces = Vector3.ZERO

func _on_damage_color_timer_timeout():
	$Pivot/Enemy/Armature_001/Skeleton3D/Mesh.set_surface_override_material(0,ENEMY_MAT)
