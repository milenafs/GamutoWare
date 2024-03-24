extends Area2D

@export var Bullet : PackedScene
#preload("res://microjogos/2024S1/projeto-asteroids/cenas/bullet.tscn")
@export var speed = 400
@export var rotation_speed = 4
var rotation_dir = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	var a = get_node("Muzzle")
	a.position = position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	if Input.is_action_pressed("ui_right"):
		rotation_dir = 1
	elif Input.is_action_pressed("ui_left"):
		rotation_dir = -1
	else:
		rotation_dir = 0
	
	if Input.is_action_just_pressed("acao"):
		shoot()
		
	rotation += rotation_dir*rotation_speed*delta
	pass
	
func shoot():
	var b = Bullet.instantiate()
	owner.add_child(b)
	b.position = $Muzzle.position
	b.rotation = $Muzzle.global_rotation
	pass
