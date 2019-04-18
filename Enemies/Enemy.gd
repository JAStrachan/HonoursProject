extends KinematicBody2D

# The a star stuff is adapted from GDQuest A star code
# https://github.com/GDquest/Godot-engine-tutorial-demos/tree/master/2018/03-30-astar-pathfinding

export(float) var SPEED = 150.0
export(float) var MASS = 10.0
export(int) var DISTANCE_FROM_THREAT = 100 # how far from the player or the threat it should be
export (int) var health = 100
export (int) var bulletDamage = 50
export (int) var vision_distance = 150

# IDLE is when the npc is just sitting around. Will every so often become idle when patrolling
# FOLLOW is when the npc is actively following a threat
# PATROL is the npc is patrolling the map following a path
# FOUNDSPOT is when npc has got in close to a threat and found a spot to fire upon
enum STATES { IDLE, FOLLOW, PATROL, FOUNDSPOT}
var _state = null

var raycast_hit_pos = [] # the positions the raycasts have hit

var detection_area_colour = Color(.867, .91, .247, 0.1)
var raycast_debug_colour = Color(1,0,0,1)

var path = []
var target
var target_point_world = Vector2()

var threats = [] # the list of threats in range
var friends = [] # the list of friends in range so we can avoid them

var Bullet = preload("res://Bullet/PlayerBullet.tscn")
var score_to_add = 20
var can_shoot = true

var velocity = Vector2()

func _ready():
	#target = get_node("/root/Map/Player")
	_change_state(STATES.PATROL)
	# Raycasting a visibiltity /area of dectection was taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	var shape = CircleShape2D.new()
	shape.radius = vision_distance
	$AreaDetection/CollisionShape2D.shape = shape

func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		path = get_parent().get_node('/root/Map/TileMap').get_world_path(position, target.position)
		if not path or len(path) == 1:
			_change_state(STATES.FOUNDSPOT)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	if new_state == STATES.FOUNDSPOT:
		velocity = position.normalized()
	
	## TODO add proper patrolling behaviour
	if new_state == STATES.PATROL:
		velocity = position.normalized()
	_state = new_state


func _process(delta):
	update()
	if _state == STATES.FOUNDSPOT:
		if (self.position.distance_to(target.position)) > DISTANCE_FROM_THREAT:
			_change_state(STATES.FOLLOW)
	if _state == STATES.FOLLOW:
		path = get_parent().get_node('/root/Map/TileMap').get_world_path(self.position, target.position)

func _physics_process(delta):
#	if _state == STATES.FOUNDSPOT:
#		detect_enemies()
#		rotate(rotation * delta) # rotates the character independant of its movement
#		shoot(target.position)
	if _state == STATES.FOLLOW or _state == STATES.FOUNDSPOT:
		detect_enemies()
		rotate(rotation * delta) # rotates the character independant of its movement
		shoot(target.position)
		
		if _state == STATES.FOLLOW:
			var arrived_to_next_point = move_to(target_point_world)
			if arrived_to_next_point:
				if len(path) != 0:
					path.remove(0)
					if len(path) == 0:
						_change_state(STATES.FOUNDSPOT)
						return
					target_point_world = path[0]
		
		
		if self.position.distance_to(target.position) < DISTANCE_FROM_THREAT:
			_change_state(STATES.FOUNDSPOT)
	
	
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
#		if collision.collider.has_method("enemy_touch"):
#			collision.collider.enemy_touch()

func move_to(world_position):
	var ARRIVE_DISTANCE = 10.0
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

# Used for detecting any threats to itself via raycasting
# Taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
func detect_enemies():
	raycast_hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var radius = 16
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
				_change_state(STATES.FOLLOW)
				break
				
func shoot(placeToShoot):
	if can_shoot:
		var bullet = Bullet.instance()
		bullet.spawn(self.global_position, rotation)
		bullet.add_collision_exception_with(self)
		get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
		can_shoot = false
		$time_since_last_shot.start()

# TODO Sort these out with threat models so they can rank the threats
func _on_AreaDetection_body_entered(body):
	# need to add this condition so it does other enemy types as well
	if body.name == "Player": 
		if target:
			return
		target = body
		_change_state(STATES.FOLLOW)

func _on_AreaDetection_body_exited(body):
	if body == target:
		velocity = position.normalized()
		$PeriodOfMemory.start()

func _on_PeriodOfMemory_timeout():
	_change_state(STATES.PATROL)
	target = null

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

func _on_time_since_last_shot_timeout():
	can_shoot = true


#extends KinematicBody2D
#

#export (int) var SPEED = 10
#
#var Bullet = preload("res://Bullet/PlayerBullet.tscn")
#

#enum TRACKING_STATE {NOT_TRACKING, TRACKING}
#var track_state = null
#
#var raycast_hit_pos = [] # the positions the raycasts have hit
#
#var detection_area_colour = Color(.867, .91, .247, 0.1)
#var raycast_debug_colour = Color(1,0,0,1)
#
#var path = []
#var velocity = Vector2()
#
## How far away from the player it should be! (roughly)
#var ARRIVE_DISTANCE = 10.0
#var score_to_add = 20
#var can_shoot = true
#
#var target	 # who we are shooting at and tracking
#var threats = [] # the list of threats in range
#var friends = [] # the list of friends in range so we can avoid them
#var target_point_world = Vector2() # where we are going next
#
#var behaviourTree
#var blackboard
#
#
#signal enemy_death
#
#func _ready():
#
#	# Raycasting a visibiltity /area of dectection was taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
#	var shape = CircleShape2D.new()
#	shape.radius = vision_distance
#	$AreaDetection/CollisionShape2D.shape = shape
#
#	can_shoot = true
#
#	add_to_group("Reds")
#	add_to_group("enemies")
#
#	_change_state(TRACKING_STATE.NOT_TRACKING)
#	blackboard = get_node("/root/Map/BehaviorBlackboard")
#	behaviourTree = get_node('/root/Map/MediumEnemy')
#
#func _change_state(newState):
#	if newState == TRACKING_STATE.TRACKING:
#		path = get_parent().get_node('TileMap').get_world_path(position, target.position)
#		if not path or len(path) == 1:
#			_change_state(TRACKING_STATE.NOT_TRACKING)
#			return
#		# The index 0 is the starting cell
#		# we don't want the character to move back to it in this example
#		target_point_world = path[1]
#	track_state = newState
#
#func bullet_hit():
#	if health - bulletDamage <= 0:
#		health = 0
#		emit_signal('enemy_death', score_to_add)
#		queue_free()
#	else:
#		health = health - bulletDamage
#
## Used for attacking the player through melee damage, currently in development as a figure out best practice	
#func hit_player():
#	pass	
#
#func _process(delta):
#	if target:
#		behaviourTree.tick(self, blackboard)
#
#func _physics_process(delta):
#	update() # allows us to draw the new debug lines every frame
#	if target:
#		var arrived_to_next_point = move_to(target_point_world)
#		if arrived_to_next_point:
#			if len(path) == 0:
#				_change_state(TRACKING_STATE.NOT_TRACKING)
#				return
#			target_point_world = path[0]
#		# if a target is within the area of vision calculate if the enemy can see the target
#		detect_enemies()
#		rotate(rotation * delta) # rotates the character independant of its movement
#		shoot(target.position)
#
#
#	var collision = move_and_collide(velocity * delta)
#	if collision:
#		velocity = velocity.bounce(collision.normal)
#		if collision.collider.has_method("enemy_touch"):
#			collision.collider.enemy_touch()
#
#func shoot(placeToShoot):
#	if can_shoot:
#		var bullet = Bullet.instance()
#		bullet.spawn(self.global_position, rotation)
#		bullet.add_collision_exception_with(self)
#		get_parent().add_child(bullet) #don't want bullet to move with me, so add it as child of parent
#		can_shoot = false
#		$time_since_last_shot.start()
#
#func move_to(world_position):
#	var MASS = 10.0
#	# How far away from the player it should be! (roughly)
#	var ARRIVE_DISTANCE = 10.0
#
#	var desired_velocity = (world_position - position).normalized() * SPEED
#	var steering = desired_velocity - velocity
#	velocity += steering / MASS 
#	position += velocity * get_process_delta_time()
#	rotation = velocity.angle()
#	return position.distance_to(world_position) < ARRIVE_DISTANCE
#
## Used for detecting any threats to itself via raycasting
## Taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
#func detect_enemies():
#	raycast_hit_pos = []
#	var space_state = get_world_2d().direct_space_state
#	var radius = 16
#	var north = target.position + Vector2(0, radius)
#	var south = target.position + Vector2(0, -radius)
#	var west = target.position + Vector2(-radius, 0)
#	var east = target.position + Vector2(radius, 0)
#
#	for pos in [target.position, north, south, west, east]:
#		# sends out raycasts into the world checking the corners and centre of the threat
#		var result = space_state.intersect_ray(position, pos, [self], collision_mask)
#		if result:
#			raycast_hit_pos.append(result.position)
#			if result.collider.name == 'Player':
#				rotation = (target.position - position).angle()
#				_change_state(TRACKING_STATE.TRACKING)
#				break
#
#func _draw():
#	pass
#    # display the visibility area
#	# this debugging code stuff is from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
##	draw_circle(Vector2(), vision_distance, detection_area_colour)
##	var radius = 25 
##
##	if target:
##		# shows collision points
##		var north = target.position + Vector2(0, radius)
##		var south = target.position + Vector2(0, -radius)
##		var west = target.position + Vector2(-radius, 0)
##		var east = target.position + Vector2(radius, 0)
##
##		for pos in [ north, south, west, east ]: 
##			draw_circle((pos - position).rotated(-rotation), 5, raycast_debug_colour)
##
##		for hit in raycast_hit_pos:
##			draw_line(Vector2(), (hit - position).rotated(-rotation), raycast_debug_colour)
##			draw_circle((hit - position).rotated(-rotation), 5, raycast_debug_colour)
#
## TODO Sort these out with threat models so they can rank the threats
#func _on_AreaDetection_body_entered(body):
#	# need to add this condition so it does other enemy types as well
#	if body.name == "Player": 
#		if target:
#			return
#		target = body
#
#func _on_AreaDetection_body_exited(body):
#	if body == target:
#		velocity = position.normalized()
#		$PeriodOfMemory.start()
#
#func _on_PeriodOfMemory_timeout():
#	target = null
#
#
#func _on_time_since_last_shot_timeout():
#	can_shoot = true
