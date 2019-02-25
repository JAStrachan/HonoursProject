extends KinematicBody2D

export (int) var health = 100
export (int) var bulletDamage = 50
export (int) var vision_distance = 100

var detection_area_colour = Color(.867, .91, .247, 0.1)
var raycast_debug_colour = Color(1,0,0,1)
var debug	# if we are in debugging state or not

var velocity = Vector2()

var raycast_hit_pos # the positions the raycasts have hit

var target	 # who we are shooting at

onready var player = $"../Player"

signal enemy_death

func _ready():
	
	# Raycasting a visibiltity /area of dectection was taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	var shape = CircleShape2D.new()
	shape.radius = vision_distance
	$AreaDetection/CollisionShape2D.shape = shape

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
	update() # allows us to draw the new debug lines every frame
	if target:
		# if a target is within the area of vision calculate if the enemy can see the target
		detect_enemies()
		
	rotate(rotation * delta) # rotates the character independant of its movement
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("enemy_touch"):
			collision.collider.enemy_touch()
			
			
# Used for detecting any threats to itself via raycasting
func detect_enemies():
	var space_state = get_world_2d().direct_space_state
	# sends out raycasts into the world
	var result = space_state.intersect_ray(position, target.position, [self], collision_mask)
	if result:
		raycast_hit_pos = result.position
		if result.collider.name == 'Player':
			rotation = (target.position - position).angle()
	
func _draw():
    # display the visibility area
	# this debugging code stuff is from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	draw_circle(Vector2(), vision_distance, detection_area_colour)
	if target:
		draw_line(Vector2(), (raycast_hit_pos - position).rotated(-rotation), raycast_debug_colour)
		draw_circle((raycast_hit_pos - position).rotated(-rotation), 5, raycast_debug_colour)

# Calculating the direction and distance from the player
func detect_player():
	var direction = player.position - self.position
	var distance = sqrt(direction.x * direction.x + direction.y * direction.y)
	if distance < vision_distance:
		look_at(player.position)

# TODO Sort these out with threat models so they can rank the threats
func _on_AreaDetection_body_entered(body):
	# need to add this condition so it does other enemy types as well
	if body.name == "Player": 
		if target:
			return
		target = body


func _on_AreaDetection_body_exited(body):
	if body == target:
		target = null
