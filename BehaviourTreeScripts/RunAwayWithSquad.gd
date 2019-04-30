extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Behaviour for running away from player, will run to another spawn location

# This also calculates the positions the squad has to be around the commander

func tick(tick):
	tick.actor.detection_area_colour = Color(0.5,0.5,0.5,0.1) # greyish
	
	var run  =  tick.blackboard.get("run", tick.tree, tick.actor)
	var target = tick.blackboard.get("target", tick.tree, tick.actor)
	
	if run:
		getPathToRunLocation(tick.actor, target, tick)
	
	#  Will stop the running once it reaches the stopping point
	tick.actor.moving_through_path()
	
	var squad = tick.blackboard.get("squad", tick.tree, tick.actor)
	var spotToMoveTo = tick.actor.calculateFollowPosition()
	
	for squadMember in squad:
		if is_instance_valid(squadMember):
			if squadMember.has_method("is_enemy"):
				squadMember.get_world_path(spotToMoveTo)
				squadMember.moving_through_path()
	
	if target:
		for squadMember in squad:
			if is_instance_valid(squadMember) and squadMember.has_method("is_enemy"):
				if squadMember.target:
					squadMember.detect_enemies()
					shoot(squadMember, tick)
			
		var line_of_sight = tick.actor.detect_enemies()
		if line_of_sight:
			tick.actor.shoot()
	
	return OK
	
func shoot(enemy, tick):
	if enemy.enemy_line_of_sight:
		enemy.shoot()
	
func getPathToRunLocation(enemy, target, tick):
	var spawnLocations = tick.blackboard.get("spawnLocations", tick.tree)
		# Collecting target
	
	var waypoint # the place to run to
	
	if target: # if a target is available to run from
		waypoint = calculateRunAwayLocation(tick, target, spawnLocations)
			
	else: # no target selected choose a random location
		randomize()
		var random_number = rand_range(0, spawnLocations.size())
		waypoint = spawnLocations[random_number]
			
	# Only need to run once
	# setting the new patrol as false by this point a new path has been created. Node and tree scope
	tick.blackboard.set("run", false ,tick.tree, tick.actor)
	
	# gets the path it needs to new spawn location
	enemy.get_world_path(waypoint)
	
func calculateRunAwayLocation(tick, target, spawnLocations):
	var biggestDifference = null
	var indexOfSpawnLocation = 0
	var vectorBetweenSelfAndTarget = tick.actor.position - target.position
	for i in range(0, spawnLocations.size()):
		var vectorBetweenSelfAndSpawnLocation = tick.actor.position - spawnLocations[i]
		
		# Looking for smallest or most negative number
		var difference = vectorBetweenSelfAndTarget - vectorBetweenSelfAndSpawnLocation
		
		if biggestDifference:
			if difference < biggestDifference:
				indexOfSpawnLocation = i
		else: # if on first location
			biggestDifference = difference
		
	return spawnLocations[indexOfSpawnLocation]