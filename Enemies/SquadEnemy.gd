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
			#get_world_path(squadLeader.position)
			
			self.detection_area_colour = Color(1, 0.501, 0.964,0.1) # purple
			
			#moving_through_path()
			
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
	


	
			
func _on_AreaDetection_body_entered(body):
	pass