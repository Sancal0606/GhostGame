extends CharacterBody3D

#velocidad de movimiento
@export var speed = 14
#Materiales
const DAMAGE_MAT = preload("res://Materials/damage.tres")
const MONKEY_MAT = preload("res://Materials/monkey_mat.tres")
#aceleracion de gravedad
@export var fall_acceleration = 75

#velocidad de rotacion
@export var rotationSpeed = 5

@export var jumpTime = 0.5
@export var jumpRange = 30


var target_velocity = Vector3.ZERO
var dir
var temp = 0
@export var maxJump = 30
var tempLength
var ghost = true
@export var maxLife = 5
var currentLife

@export var damageCooldown = 0.5
var damageCount = 0.5

var additional_forces = Vector3(0,0,0)
@export var damage_force = 10

func _ready():
	currentLife = maxLife
	tempLength = maxJump
	ghost = true
	damageCount = damageCooldown

func _process(delta):
	damageCount -= delta
	if velocity.length() > 0.1:
		
		$Pivot/monkey_prueba/AnimationTree["parameters/Movement/blend_amount"] \
		= lerp($Pivot/monkey_prueba/AnimationTree["parameters/Movement/blend_amount"],1.0,delta * 10)
	else:
		$Pivot/monkey_prueba/AnimationTree["parameters/Movement/blend_amount"] \
		= lerp($Pivot/monkey_prueba/AnimationTree["parameters/Movement/blend_amount"],0.0,delta * 10)
	if damageCount <= 0:
		$Pivot/monkey_prueba/Armature/Skeleton3D/monkey.set_surface_override_material(0,MONKEY_MAT)

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
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		jump()
	else:
		move(direction, delta)
	
	#Agrega la velocidad de caida
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		temp += delta
		tempLength = 10000
	else:
		tempLength = maxJump
		#print(temp)
	
	dir = $"..".lookDirection
	#print(dir)
	#print(position)
	var tempVec =  dir - position 
	tempVec.y = 0
	var tempVecNor = tempVec.normalized()
	#Asegura que el cursor no pase de la distancia maxima
	
	var tempVec2 = tempVecNor * clampf(tempVec.length(),0,jumpRange) + position
	tempVec2.y = 0
	#$Ball.position = tempVec2
	$"../Ball".position = tempVec2
	velocity = target_velocity
	velocity += additional_forces
	move_and_slide()
	
	check_collisions()
	
func jump():
	
	var tempVec = dir - position
	tempVec.y = 0
	var tempVecNor = tempVec.normalized()
	tempVec = tempVecNor * clampf(tempVec.length(),0,tempLength)
	tempVec.y = 0
	
	if is_on_floor():
		$"../Ball2".position = tempVec + position * Vector3(1,0,1)
	else:
		$"../Ball2".position = dir
	target_velocity.y = fall_acceleration * jumpTime
	target_velocity.x = tempVec.x / (jumpTime * 2)
	target_velocity.z = tempVec.z / (jumpTime * 2)
	
func move(direction, delta):
	#Gira el personaje hacia la direccion del movimiento
	if direction != Vector3.ZERO or not is_on_floor():
		direction = direction.normalized()
		var look_direction = Vector2(velocity.z,velocity.x)
		$Pivot.rotation.y = lerp_angle($Pivot.rotation.y,look_direction.angle(),delta * rotationSpeed)
		#$Pivot.basis = Basis.looking_at(-direction)
	
	if is_on_floor():
		#Guarda las velocidades multiplicadas por la velocidad
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
		
func check_collisions():
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		
		if collision.get_collider() == null:
			continue
		
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1 and ghost:
				position = Vector3(100,100,100)
				mob.posses()
				ghost = false
				break

func returnPossesion(pos):
	damageCount = damageCooldown
	show()
	ghost = true
	position=pos

func take_damage(_damage,_dir):
	if damageCount <= 0:
		$Pivot/monkey_prueba/Armature/Skeleton3D/monkey.set_surface_override_material(0,DAMAGE_MAT)
		damageCount = damageCooldown
		currentLife -= _damage
		additional_forces = _dir * damage_force
		$Damage_Timer.start()
		if currentLife <= 0:
			$"..".game_over()
		
func _on_damage_timer_timeout():
	additional_forces = Vector3.ZERO
