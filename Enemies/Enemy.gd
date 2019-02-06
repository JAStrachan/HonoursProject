extends KinematicBody2D

export (int) var health = 100
export (int) var bulletDamage = 50
export (int) var vision_distance = 100
var velocity = Vector2()

onready var player = $"../Player"

signal enemy_death

func _ready():
	
	pass

func bullet_hit():
	if health - bulletDamage <= 0:
		health = 0
		emit_signal('enemy_death')
		queue_free()
	else:
		health = health - bulletDamage
	
# Used for attacking the player through melee damage, currently in development as a figure out best practice	
func hit_player():
	pass

func _physics_process(delta):
	# calculating the direction and distance from the player
	
	var direction = player.position - self.position
	var distance = sqrt(direction.x * direction.x + direction.y * direction.y)
	if distance < vision_distance:
		look_at(player.position)
		
	rotate(rotation * delta) # rotates the character independant of its movement
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("enemy_touch"):
			collision.collider.enemy_touch()
