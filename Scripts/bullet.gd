extends Area3D

@export var speed = 2
@export var damage = 1
@export var hit: PackedScene
var direction

func _initialize(_dir):
	direction = _dir

func _physics_process(delta):
	print(priority * speed)
	if direction:
		position += direction * speed * delta * 10
	

func _on_body_entered(body):
	var hit_temp = hit.instantiate()
	hit_temp.position = position
	
	$"..".add_child(hit_temp)
	queue_free()
	if body.has_method("take_damage"):
		var _dir = direction.normalized()
		_dir.y = 0
		body.take_damage(damage,_dir)
