extends KinematicBody2D

export (int) var health = 100
export (int) var bulletDamage = 50
export (int) var vision_distance = 150

var raycast_hit_pos = [] # the positions the raycasts have hit

var detection_area_colour = Color(.867, .91, .247, 0.1)
var raycast_debug_colour = Color(1,0,0,1)
var debug	# if we are in debugging state or not

var velocity = Vector2()

var target	 # who we are shooting at

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
# Taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
func detect_enemies():
	raycast_hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var radius = 25 # TODO set this to 16 when you have resized the sprites
	var north = target.position + Vector2(0, radius)
	var south = target.position + Vector2(0, -radius)
	var west = target.position + Vector2(-radius, 0)
	var east = target.position + Vector2(radius, 0)
	
	for pos in [target.position, north, south, west, east]:
		# sends out raycasts into the world checking the corners and centre of the threat
		var result = space_state.intersect_ray(position, pos, [self], collision_mask)
		if result:
			raycast_hit_pos.append(result.position)
			if result.collider.name == 'Player':
				rotation = (target.position - position).angle()
				break
	
# for squares
#func get_edges_of_target():
## The corners of the threat
#	var target_extents = target.get_node('CollisionShape2D').shape.extents - Vector2(5, 5)
#	var nw = target.position - target_extents
#	var se = target.position + target_extents
#	var ne = target.position + Vector2(target_extents.x, -target_extents.y)
#	var sw = target.position + Vector2(-target_extents.x, target_extents.y)

func _draw():
    # display the visibility area
	# this debugging code stuff is from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	draw_circle(Vector2(), vision_distance, detection_area_colour)
	var radius = 25 
	
	if target:
		# shows collision points
		var north = target.position + Vector2(0, radius)
		var south = target.position + Vector2(0, -radius)
		var west = target.position + Vector2(-radius, 0)
		var east = target.position + Vector2(radius, 0)
		
		for pos in [ north, south, west, east ]: 
			draw_circle((pos - position).rotated(-rotation), 5, raycast_debug_colour)
			
		for hit in raycast_hit_pos:
			draw_line(Vector2(), (hit - position).rotated(-rotation), raycast_debug_colour)
			draw_circle((hit - position).rotated(-rotation), 5, raycast_debug_colour)

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
