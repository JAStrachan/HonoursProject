extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Allows patrolling with squads

func tick(tick):	
	var newPatrol = tick.blackboard.get("newPatrol", tick.tree, tick.actor)
	
	if newPatrol:
		var spawnLocations = tick.blackboard.get("spawnLocations", tick.tree)
		# If a new patrol route (ie to new spawn location then)
		randomize()
		var random_number = rand_range(0, spawnLocations.size())
		
		var waypoint = spawnLocations[random_number]
		
		# gets the path it needs to new spawn location
		tick.actor.get_world_path(waypoint)
		
		newPatrol = false
		# setting the new patrol as false by this point a new path has been created. Node and tree scope
		tick.blackboard.set("newPatrol", newPatrol ,tick.tree, tick.actor)
		
	# Will correct newPatrol to true if end of path is reached
	tick.actor.moving_through_path()
	
	var squad = tick.blackboard.get("squad", tick.tree, tick.actor)
	var spotToMoveTo = tick.actor.calculateFollowPosition()
	
	for squadMember in squad:
		if is_instance_valid(squadMember):
			squadMember.get_world_path(spotToMoveTo)
			squadMember.moving_through_path()
	
	tick.actor.detection_area_colour = Color(.867, .91, .247, 0.1) # yellow
	
	return OK