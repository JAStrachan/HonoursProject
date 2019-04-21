extends KinematicBody2D

# The a star stuff is adapted from GDQuest A star code
# https://github.com/GDquest/Godot-engine-tutorial-demos/tree/master/2018/03-30-astar-pathfinding

export(float) var SPEED = 150.0
export(float) var MASS = 10.0
export(int) var DISTANCE_FROM_THREAT = 100 # how far from the player or the threat it should be
export (int) var health = 100
export (int) var totalHealth = 100
var healthLow = false
export (int) var vision_distance = 150
export (bool) var can_shoot = true
export (int) var score_to_add = 20

# IDLE is when the npc is just sitting around. Will every so often become idle when patrolling
# TRACKING is when the npc is actively following a threat
# PATROL is the npc is patrolling the map following a path
# RANGED_ATTACK is when npc has got in close to a threat and found a spot to fire upon LINE OF SIGHT
# CHASE is when npc is following a threat and has a line of sight on it
enum STATES { IDLE, TRACKING, PATROL, RANGED_ATTACK, CHASE, RUN}
var _state = null

var raycast_hit_pos = [] # the positions the raycasts have hit

var detection_area_colour = Color(.867, .91, .247, 0.1)
var raycast_debug_colour = Color(1,0,0,1)

var path = []
var target
var target_point_world = Vector2() # the next point in the path

var threats = [] # the list of threats in range
var friends = [] # the list of friends in range so we can avoid them
var enemy_line_of_sight = false

var Bullet = preload("res://Bullet/PlayerBullet.tscn")

var velocity = Vector2()

signal enemy_death

onready var blackboard = get_node("/root/Map/Blackboard")
onready var behaviourTree = get_node('/root/Map/MediumEnemy')

func _ready():
	_change_state(STATES.PATROL)
	# Raycasting a visibiltity /area of dectection was taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	var shape = CircleShape2D.new()
	shape.radius = vision_distance
	$AreaDetection/CollisionShape2D.shape = shape

func _change_state(new_state):
	if new_state == STATES.TRACKING:
		# Calculates path in the physics_process
		detection_area_colour = Color(0,1,0,0.1) # green
		
	if new_state == STATES.CHASE:
		# Calculates path in the physics_process
		detection_area_colour = Color(1,0,0,0.1) # red
		
	if new_state == STATES.IDLE:
		velocity = Vector2(0,0)
		detection_area_colour = Color(.867, .91, .247, 0.1) # yellow
	
	if new_state == STATES.RANGED_ATTACK:
		velocity = Vector2(0,0)
		detection_area_colour = Color(0, 0.764, 0.819,0.1) # cyan-ish
		
	## TODO add proper patrolling behaviour
	if new_state == STATES.PATROL:
		velocity = Vector2(0,0)
		detection_area_colour = Color(.867, .91, .247, 0.1) # yellow
		
	_state = new_state

func _process(delta):
	update() # Used to add the drawing of the debugging behaviour
	#pass
	

func _physics_process(delta):
	if blackboard and behaviourTree:
		if target:
			blackboard.set("target", target, behaviourTree)
		behaviourTree.tick(self, blackboard)
	
	if _state == STATES.RANGED_ATTACK:
		# Switch back to following threat if it is far away enough
		var distanceToTarget = self.position.distance_to(target.position)
		if distanceToTarget > DISTANCE_FROM_THREAT + 10 or not enemy_line_of_sight :
			_change_state(STATES.TRACKING)
		elif distanceToTarget > DISTANCE_FROM_THREAT + 10 and enemy_line_of_sight :
			_change_state(STATES.CHASE)
			
	if _state == STATES.TRACKING or _state == STATES.CHASE:
		path = get_parent().get_node('/root/Map/TileMap').get_world_path(self.position, target.position)
		target_point_world = path[1]
		if enemy_line_of_sight:
			_change_state(STATES.CHASE)
			
	# if it is attacking do
	if _state == STATES.TRACKING or _state == STATES.RANGED_ATTACK or _state == STATES.CHASE:
		detect_enemies() # determines which way the character faces if line of sight can be achieved
		if _state == STATES.TRACKING or _state == STATES.CHASE:
			var arrived_to_next_point = move_to(target_point_world)
			if arrived_to_next_point:
				# moving through the path points
				if len(path) != 0:
					path.remove(0)
					# if it is at the end of it's path
					if len(path) == 0:
						if enemy_line_of_sight:
							_change_state(STATES.RANGED_ATTACK)
						else:
							_change_state(STATES.IDLE)
						return
					target_point_world = path[0]
		
		if _state == STATES.RANGED_ATTACK or _state == STATES.CHASE:
			shoot()
		
		var distanceToTarget = self.position.distance_to(target.position)
		if distanceToTarget < DISTANCE_FROM_THREAT and not _state == STATES.RANGED_ATTACK  :
			_change_state(STATES.RANGED_ATTACK)
	
	rotate(rotation * delta) # rotates the character independant of its movement
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("enemy_touch"):
			collision.collider.enemy_touch()

func move_to(world_position):
	var ARRIVE_DISTANCE = 10.0 # distance it needs to hit for the point on path to start considering the next point
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	if not enemy_line_of_sight:
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
			# TODO Add for allowing to hit the other threats
			if result.collider.name == 'Player':
				# Changes state to follow the threat
				enemy_line_of_sight = true
				rotation = (target.position - position).angle()
				#_change_state(STATES.TRACKING)
				break
	return enemy_line_of_sight
# Shoots in the direction it is facing in
func shoot():
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
		target = body
		
		_change_state(STATES.TRACKING)
		
	if target == body and $PeriodOfMemory.get_time_left() > 0:
		$PeriodOfMemory.stop()

func _on_AreaDetection_body_exited(body):
	if body == target:
		$PeriodOfMemory.start()

# For how long it can track a threat for once it is out of it's vision
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

# Time in between shots
func _on_time_since_last_shot_timeout():
	can_shoot = true
	
func bullet_hit(bullet_damage):
	if health - bullet_damage <= 0:
		# death
		Global.update_enemy_count()
		emit_signal("enemy_death", score_to_add)
		queue_free()
	else:
		health = health - bullet_damage
		if health < totalHealth/2:
			healthLow = true

func heal(healthToAdd):
	health += healthToAdd
	if health > totalHealth/2:
		healthLow = false