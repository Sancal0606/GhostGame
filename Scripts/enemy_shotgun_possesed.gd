extends CharacterBody3D

var target

#velocidad de movimiento
@export var speed = 14

#velocidad de rotacion
@export var rotationSpeed = 5
@export var bullet: PackedScene
@export var flash: PackedScene
@export var life = 1
@export var angleDelta = 5
@export var cooldown = 2.0
@export var damageCooldown = 0.5
var damageCount = 0.5
var countShot

var target_velocity = Vector3.ZERO
var dir
var player
var temp
var additional_forces = Vector3(0,0,0)
@export var damage_force = 10

#Materiales
@export var DAMAGE_MAT = preload("res://Materials/damage.tres")
@export var ENEMY_MAT = preload("res://Materials/soldier_shotgun_possessed.tres")

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	#Registra el input de los controles
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_front"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("Shoot") and countShot <= 0:
		shoot()
	countShot -= delta
	#Gira el personaje hacia la direccion del movimiento
	
	temp = $"..".lookDirection - position
	temp = temp.normalized()
	var look_direction = Vector2(temp.z,temp.x)
	$Pivot.rotation.y = lerp_angle($Pivot.rotation.y,look_direction.angle(),delta * rotationSpeed)
	#$Pivot.basis = Basis.looking_at(-direction)
	
	direction = direction.normalized()
	#Guarda las velocidades multiplicadas por la velocidad
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
		
	velocity = target_velocity
	velocity += additional_forces
	move_and_slide()
	
func _process(delta):
	damageCount -= delta	
	if damageCount <= 0:
		$Pivot/Possessed/Armature_001/Skeleton3D/Cube_001.set_surface_override_material(0,ENEMY_MAT)
	
func initialize():
	countShot = 0
	damageCount = damageCooldown

func return_possesion():
	$"..".destroy_enemy(self)
	$"..".returnTarget(position)
	queue_free()

func _on_timer_timeout():
	return_possesion()
	
func take_damage(_damage,_dir):
	if damageCount <= 0:
		$Pivot/Possessed/Armature_001/Skeleton3D/Cube_001.set_surface_override_material(0,DAMAGE_MAT)
		damageCount = damageCooldown
		additional_forces = _dir * damage_force
		$Damage_Timer.start()
		life -= _damage
		if life <= 0:
			die()
	
func die():
	return_possesion()

func shoot():
	countShot = cooldown
	var flashTemp = flash.instantiate()
	flashTemp.global_position = $Pivot/BulletPoint.global_position
	$"..".add_child(flashTemp)
	#Get angles
	var dirTemp = temp
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
	
	var look_direction1 = Vector2(dirTemp.z,dirTemp.x)
	var look_direction2 = Vector2(dirMin.z,dirMin.x)
	var look_direction3 = Vector2(dirMax.z,dirMax.x)
	
	bulletTemp1.rotation.y = look_direction1.angle()
	bulletTemp2.rotation.y = look_direction2.angle()
	bulletTemp3.rotation.y = look_direction3.angle()
	
	bulletTemp1.scale = Vector3(6,6,6)
	bulletTemp2.scale = Vector3(6,6,6)
	bulletTemp3.scale = Vector3(6,6,6)
	
	bulletTemp1._initialize(dirTemp)
	bulletTemp2._initialize(dirMin)
	bulletTemp3._initialize(dirMax)
	
	$"..".add_child(bulletTemp1)
	$"..".add_child(bulletTemp2)
	$"..".add_child(bulletTemp3)
	


func _on_damage_timer_timeout():
	additional_forces = Vector3.ZERO
