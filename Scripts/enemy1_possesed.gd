extends CharacterBody3D

var target

#velocidad de movimiento
@export var speed = 14

#velocidad de rotacion
@export var rotationSpeed = 5
@export var bullet: PackedScene
@export var life = 15
@export var cooldown = 2.0
var countShot

@export var damageCooldown = 0.5
var damageCount = 0.5

var target_velocity = Vector3.ZERO
var dir
var player
var temp

var additional_forces = Vector3(0,0,0)
@export var damage_force = 10

#Materiales
@export var DAMAGE_MAT = preload("res://Materials/damage.tres")
@export var ENEMY_MAT = preload("res://Materials/soldier_possessed.tres")

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
		$Pivot/Possessed/Armature/Skeleton3D/Mesh.set_surface_override_material(0,ENEMY_MAT)
	
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
	print(damageCount)
	if damageCount <= 0:
		$Pivot/Possessed/Armature/Skeleton3D/Mesh.set_surface_override_material(0,DAMAGE_MAT)
		damageCount = damageCooldown
		life -= _damage
		additional_forces = _dir * damage_force
		$Damage_Timer.start()
		if life <= 0:
			die()
	
func die():
	return_possesion()

func shoot():
	var bulletTemp = bullet.instantiate()
	bulletTemp.global_transform = $Pivot/BulletPoint.global_transform
	bulletTemp.scale = Vector3(6,6,6)
	var look_direction = Vector2(temp.z,temp.x)
	bulletTemp.rotation.y = look_direction.angle()
	$Pivot/Flash/AnimationPlayer.play("slash")
	var tTemp = temp
	tTemp.y = 0
	countShot = cooldown
	bulletTemp._initialize(tTemp)
	$"..".add_child(bulletTemp)
	
func _on_damage_timer_timeout():
	additional_forces = Vector3.ZERO
