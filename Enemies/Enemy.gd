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
export (float) var lowHealthPercentage = 0.4  # determines exactly at what percentage of health does an enemy run
export (String) var behaviourTreePath = '/root/Map/MediumEnemyTree'

var raycast_hit_pos = [] # the positions the raycasts have hit

var detection_area_colour = Color(.867, .91, .247, 0.1)
var raycast_debug_colour = Color(1,0,0,1)

var path = []
var target
var target_point_world = Vector2() # the next point in the path

var enemy_line_of_sight = false

var Bullet = preload("res://Bullet/EnemyBullet.tscn")

var velocity = Vector2()

signal enemy_death # emitted in the child classes who all specific death functions

onready var tileMap = get_parent().get_node('/root/Map/TileMap')

onready var blackboard = get_node("/root/Map/Blackboard")
onready var behaviourTree = get_node(behaviourTreePath)

func _ready():
	# Raycasting a visibiltity /area of dectection was taken from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	var shape = CircleShape2D.new()
	shape.radius = vision_distance
	$AreaDetection/CollisionShape2D.shape = shape
	
	# So we can collect information about it without a direct reference to the exact node it is
	add_to_group("enemies")
	
	$AreaDetection.connect("body_entered", self, "_on_AreaDetection_body_entered")
	$AreaDetection.connect("body_exited", self, "_on_AreaDetection_body_exited")
	
	# Sets it so a new patrol is wanted when spawned
	blackboard.set("newPatrol", true, behaviourTree, self)
	
# For random spawning, gives correct position on map
func spawn(pos):
	position = pos
	

func _process(delta):
	update() # Used to add the drawing of the debugging behaviour
	
# The main loop that iterates at a fixed process
func _physics_process(delta):
	
	useBehaviourTrees()
	
	rotate(rotation * delta) # rotates the character independant of its movement
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("enemy_touch"):
			collision.collider.enemy_touch()
			
func useBehaviourTrees():
	if blackboard and behaviourTree:
		var spawnLocations = tileMap.getSpawnLocations()
		if target:
			blackboard.set("target", target, behaviourTree, self)
			blackboard.set("distance_from_threat", DISTANCE_FROM_THREAT, behaviourTree, self)
			
		blackboard.set("spawnLocations", spawnLocations, behaviourTree)
		behaviourTree.tick(self, blackboard)

# calculates the velcocity and the rotation (if we don't have line of sight, as then rotation gets overwritten)
func move_to(world_position):
	var ARRIVE_DISTANCE = 10.0 # distance it needs to hit for the point on path to start considering the next point
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	if not enemy_line_of_sight:
		rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

# calculates if the npc has arrived to the next path point and if it is at the end of its path
func moving_through_path():
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
	# moving through the path points
		if len(path) != 0:
			path.remove(0)
			# if it is at the end of it's path
			if len(path) == 0:
				stop_movement()
				# Needs another patrol route set up, node and tree scope
				blackboard.set("newPatrol", true, behaviourTree, self)
				
				healthLow = false
				
			if len(path) != 0:
				target_point_world = path[0]
			else:
				target_point_world = self.position
			
# gets the path within in the world that the npc wants to follow
func get_world_path(target_position):
	path = tileMap.get_world_path(self.position, target_position)
	if path.size() > 1:
		target_point_world = path[1]
	else:
		pass
	
# A function that stops movement of the npc. So the flow for stopping is always through here and easily trackable
func stop_movement():
	velocity = Vector2(0,0)
	
# Used for detecting any threats to itself via raycasting, also calculates the rotation for turning to face threat
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
		blackboard.set("target", target, behaviourTree, self)
		
	# So if the timer has started and the threat has entered the area of detection again stop the timer
	if target == body and $PeriodOfMemory.get_time_left() > 0:
		$PeriodOfMemory.stop()

# Start the timer to stop following the threat
# Once the threat has left the area of detection for a period of time stop following them
func _on_AreaDetection_body_exited(body):
	if body == target:
		$PeriodOfMemory.start()

# For how long it can track a threat for once it is out of it's vision
func _on_PeriodOfMemory_timeout():
	target = null
	blackboard.set("target", target, behaviourTree, self)

func _draw():
    # display the visibility area
	# this debugging code stuff is adapted from http://kidscancode.org/blog/2018/03/godot3_visibility_raycasts/
	if Global.debug_mode:
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
	else:
		pass
		
# Time in between shots
func _on_time_since_last_shot_timeout():
	can_shoot = true
	
# Method for duck-typing, if a bullet hits use this method
func bullet_hit(bullet_damage):
	if health - bullet_damage <= 0:
		Global.update_score(score_to_add)
		death()
	else:
		health = health - bullet_damage
		if health/totalHealth < lowHealthPercentage and not healthLow:
			# Only set this code running once everytime health dips below the limit
			healthLow = true
			# Set the actor to run
			blackboard.set("run", true, behaviourTree, self)

func death():
	Global.update_enemy_death_count()
	deathCount() # is used by child classes to tell Global how much of each type of enemy is left
	target = null
	blackboard.set("target", target, behaviourTree, self)
	emit_signal("enemy_death", score_to_add)
	
	queue_free()
	
func deathCount():
	# Is overridden in child classes
	pass
	
# Duck typing heal method. Interacts with health boosts
func heal(healthToAdd):
	health += healthToAdd
	if health > totalHealth/2:
		healthLow = false

func _on_ResetPatrol_timeout():
	# Needs another patrol route set up, node and tree scope
	blackboard.set("newPatrol", true, behaviourTree, self)
	
func is_enemy():
	pass # a method that tells you that identity of the class you are checking