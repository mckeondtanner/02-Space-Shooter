extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 5.0
var max_speed = 400.0
var rot_speed = 5.0

var nose = Vector2(0, -60)
var health = 10
var shields = 0
var shield_regen = 0.1
var shield_max = 50
var shield_textures = [
	preload("res://Assets//spaceshooter/PNG/Effects/shield1.png"),
	preload("res://Assets//spaceshooter/PNG/Effects/shield2.png"),
	preload("res://Assets//spaceshooter/PNG/Effects/shield3.png")
]

onready var Bullet = load("res://Player/Bullet.tscn")
onready var Explosion = load("res://Effects/Explosion.tscn")
var Effects = null

func _ready():
	pass

func _physics_process(_delta):
	velocity += get_input()*speed
	velocity = velocity.normalized() * clamp(velocity.length(), 0, max_speed)
	velocity = move_and_slide(velocity, Vector2.ZERO)
	position.x = wrapf(position.x, 0.0, Global.VP.x)
	position.y = wrapf(position.y, 0.0, Global.VP.y)

	shields = clamp(shields + shield_regen, -100, shield_max)
	if shields >= shield_max:
		$Shield.hide()
	elif shields >= shield_max * 0.75:
		$Shield.show()
		$Shield/Sprite.texture = shield_textures[2]
	elif shields >= shield_max * 0.4:
		$Shield.show()
		$Shield/Sprite.texture = shield_textures[1]
	elif shields > 0:
		$Shield.show()
		$Shield/Sprite.texture = shield_textures[0]
	else:
		$Shield.hide()

func get_input():
	var dir = Vector2.ZERO
	$Exhaust_Container/Exhaust.hide()
	if Input.is_action_pressed("up"):
		$Exhaust_Container/Exhaust.show()
		dir += Vector2(0, -1)
	if Input.is_action_pressed("left"):
		rotation_degrees -= rot_speed
	if Input.is_action_pressed("right"):
		rotation_degrees += rot_speed
	if Input.is_action_just_pressed("shoot"):
		shoot()
	return dir.rotated(rotation)

func shoot():
	Effects = get_node_or_null("/root/Game/Effects")
	if Effects != null:
		var bullet = Bullet.instance()
		Effects.add_child(bullet)
		bullet.rotation = rotation
		bullet.global_position = global_position + nose.rotated(rotation)

func damage(d):
	health -= d
	if health <= 0:
		Effects = get_node_or_null("/root/Game/Effects")
		if Effects != null:
			var explosion = Explosion.instance()
			explosion.global_position = global_position
			Effects.add_child(explosion)
		Global.update_lives(-1)
		queue_free()

func _on_Area2D_body_entered(body):
	if body.name != "Player":
		if body.has_method("damage"):
			body.damage(100)
		damage(100)


func _on_Shield_area_entered(area):
	if "damage" in area and not area.is_in_group("friendly") and shields >= 0:
		shields -= area.damage
		area.queue_free()

func _on_Shield_body_entered(body):
	if body != self and not body.is_in_group("friendly") and body.has_method("damage") and shields >= 0:
		shields -= 100
		body.damage(100)
