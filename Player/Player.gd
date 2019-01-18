extends KinematicBody2D

export (int) var speed = 200

export (float) var shoot_speed = 0.5


var velocity = Vector2()
var can_shoot = true

var Bullet = preload("res://Bullet/PlayerBullet.tscn")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	can_shoot = true

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
	rotate(rotation * delta)
	
	# Used from https://docs.godotengine.org/en/latest/tutorials/physics/using_kinematic_body_2d.html
	if Input.is_action_pressed('ui_shoot'):
		if can_shoot:
			var bullet = Bullet.instance()
			bullet.spawn(self.global_position, rotation)
			bullet.add_collision_exception_with(self)
			get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
			can_shoot = false
			$time_since_last_shot.start()
	
	
func _physics_process(delta):
	get_input(delta)
	move_and_slide(velocity)


func _on_time_since_last_shot_timeout():
	can_shoot = true
