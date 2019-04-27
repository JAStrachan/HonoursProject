extends "res://Enemies/Enemy.gd"


var inSquad = false
var squadLeader

func addedToSquad(leader):
	inSquad = true
	squadLeader = leader
	
func _physics_process(delta):
	# useBehaviourTrees is used in Parent here, overwritten here with code I want
	# All the other code is called in the parent's physics process
	pass
			
func useBehaviourTrees():
	if blackboard and behaviourTree:
		# if not inSquad use the individual behaviour tree structures
		if not inSquad:
			var spawnLocations = tileMap.getSpawnLocations()
			if target:
				blackboard.set("target", target, behaviourTree, self)
				blackboard.set("distance_from_threat", DISTANCE_FROM_THREAT, behaviourTree, self)
					
			blackboard.set("spawnLocations", spawnLocations, behaviourTree)	
			behaviourTree.tick(self, blackboard)
		else:
			
			self.detection_area_colour = Color(1, 0.501, 0.964,0.1) # purple
			
# calculates the velocity and the rotation (if we don't have line of sight, as then rotation gets overwritten)
# Steering behaviour algorithms written in flash https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-leader-following--gamedev-10810
# Rewritten into GDScript by me
func move_to(world_position):
	var ARRIVE_DISTANCE = 10.0 # distance it needs to hit for the point on path to start considering the next point
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	if not enemy_line_of_sight:
		rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

# TODO Sort these out with threat models so they can rank the threats
func _on_AreaDetection_body_entered(body):
	# need to add this condition so it does other enemy types as well
	if body.name == "Player": 
		target = body
		if inSquad:
			if is_instance_valid(squadLeader):
				squadLeader.update_squad_target(target)
		blackboard.set("target", target, behaviourTree, self)
		
	# So if the timer has started and the threat has entered the area of detection again stop the timer
	if target == body and $PeriodOfMemory.get_time_left() > 0:
		$PeriodOfMemory.stop()


# For how long it can track a threat for once it is out of it's vision
func _on_PeriodOfMemory_timeout():
	if inSquad:
		if not squadLeader.target:
			target = null
	else:
		target = null
		blackboard.set("target", target, behaviourTree, self)
		
func squadDisbanded():
	inSquad = false
	squadLeader = null