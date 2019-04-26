extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Behaviour for running away from player, will run to another spawn location

# This also calculates the positions the squad has to be around the commander

func tick(tick):
	tick.actor.detection_area_colour = Color(0.5,0.5,0.5,0.1) # greyish
	
	var run  =  tick.blackboard.get("run", tick.tree, tick.actor)
	var target = tick.blackboard.get("target", tick.tree, tick.actor)
	
	if run:
		var spawnLocations = tick.blackboard.get("spawnLocations", tick.tree)
		# Collecting target

		
		var waypoint # the place to run to
		
		if target: # if a target is available to run from
			waypoint = calculateRunAwayLocation(tick, target, spawnLocations)
				
		else: # no target selected choose a random location
			randomize()
			var random_number = rand_range(0, spawnLocations.size())
			waypoint = spawnLocations[random_number]
		
		# gets the path it needs to new spawn location
		tick.actor.get_world_path(waypoint)
		
		# Only need to run once
		run = false
		# setting the new patrol as false by this point a new path has been created. Node and tree scope
		tick.blackboard.set("run", run ,tick.tree, tick.actor)
	
	#  Will stop the running once it reaches the stopping point
	tick.actor.moving_through_path()
	
	if target:
		var line_of_sight = tick.actor.detect_enemies()
		if line_of_sight:
			tick.actor.shoot()
	
	return OK
	
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