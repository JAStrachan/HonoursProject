extends "res://Enemies/LargeEnemy.gd"

export (int) var maxSquadTotal = 7 # 8 including the commander
export (int) var maxGruntTotal = 3
export (int) var BEHIND_LEADER_DIST = 30


onready var gruntTotal = 0
onready var ratTotal = 0

var squad = [] # the list of squad members

func useBehaviourTrees():
	if blackboard and behaviourTree:
		var spawnLocations = tileMap.getSpawnLocations()
		if target:
			blackboard.set("target", target, behaviourTree, self)
			blackboard.set("distance_from_threat", DISTANCE_FROM_THREAT, behaviourTree, self)
		
		blackboard.set("squad", squad, behaviourTree, self)
		blackboard.set("spawnLocations", spawnLocations, behaviourTree)
		behaviourTree.tick(self, blackboard)

func _on_AreaDetection_body_entered(body):
#	# need to add this condition so it does other enemy types as well
#	if body.name == "Player": 
#		target = body
#		blackboard.set("target", target, behaviourTree, self)
#
#	# So if the timer has started and the threat has entered the area of detection again stop the timer
#	if body.name == "Player" and $PeriodOfMemory.get_time_left() > 0:
#		$PeriodOfMemory.stop()
		
	if body.has_method("addedToSquad"):
		if not body.inSquad:
			addToSquad(body)
		
func addToSquad(body):
	if squad.find(body) == -1:
		if squad.size() < maxSquadTotal: # If there isn't too many already
			if body.has_method("grunt"):
				if gruntTotal < maxGruntTotal: # checks if there is too many grunts
					squad.append(body)
					gruntTotal += 1
			else:
				ratTotal += 1
				squad.append(body)
			if body.has_method("addedToSquad"):
				body.addedToSquad(self) #Tells squad members to follow the commander's orders
		
func _on_squad_members_death(deadMember):
	for i in range(0, squad.size()):
		if squad[i] == deadMember:
			squad.remove(i)
				
func calculateFollowPosition():
	var spot: Vector2 = self.velocity * -1 # get the negative velocity of the leader
	spot = spot.normalized() * BEHIND_LEADER_DIST # gets the direction and length of one to times it by the distance we want
	return spot + self.position
	

