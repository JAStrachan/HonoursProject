extends KinematicBody2D

export (int) var speed = 200

export (int) var health = 100
export (int) var max_health = 150
export (int) var enemy_physical_attack = 20

var score

signal death
signal health_changed
signal score_changed


var velocity = Vector2()
var can_shoot = true

var Bullet = preload("res://Bullet/PlayerBullet.tscn")

onready var springarm = $'Pivot'

func _ready():
	can_shoot = true
	score = 0
# Basic movement taken from tutorial at http://docs.godotengine.org/en/3.0/tutorials/2d/2d_movement.html
func get_input(delta):
	# Get the mouse position and the angle we need to point ourselves to it
	# Gives that in radians to 'rotation' a field of a parent class
	look_at(get_global_mouse_position())
	
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	# normalised the velocity otherwise going diagonal would be faster
	velocity = velocity.normalized() * speed
	
	rotate(rotation * delta) # rotates the character independant of its movement
	springarm.rotate(rotation * delta) # rotates the camera so you always see a little in front of you

	if Input.is_action_pressed('ui_shoot'):
		shoot()
	
	
func _physics_process(delta):
	get_input(delta)
#	var collision = move_and_collide(velocity * delta)
#	if collision:
#		velocity = velocity.slide(collision.normal)
#		# For collision with enemies that are still as the collision dectection only works when something is moving
#		if collision.collider.has_method("hit_player"):
#			velocity = velocity.bounce(collision.normal)
#			enemy_touch()
#		else:
#			# Have this so player's will bounce off enemies but slide along walls
#			pass
	var collision = move_and_slide(velocity)

func _on_time_since_last_shot_timeout():
	can_shoot = true

# Used from https://docs.godotengine.org/en/latest/tutorials/physics/using_kinematic_body_2d.html
func shoot():
	if can_shoot:
		var bullet = Bullet.instance()
		bullet.spawn(self.global_position, rotation)
		bullet.add_collision_exception_with(self)
		get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
		can_shoot = false
		$time_since_last_shot.start()
		
# if an enemy physically attacks a player (ie touches a player)
func enemy_touch():
	hit(enemy_physical_attack)
	
func heal(health_boost):
	health = health + health_boost
	if health > max_health:
		health = max_health
	emit_signal('health_changed', health)

func hit(damage):
	if health - damage <=0:
		emit_signal("death")
		emit_signal('health_changed', 0)
		death()
	else:
		health = health - damage
		emit_signal('health_changed', health)
		
func death():
	queue_free()

func _on_Enemy_enemy_death(add_to_score):
	score = score + add_to_score
	emit_signal('score_changed', score)
