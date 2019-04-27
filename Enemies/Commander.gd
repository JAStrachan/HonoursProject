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
	# need to add this condition so it does other enemy types as well
	if body.name == "Player": 
		update_squad_target(body)

	# So if the timer has started and the threat has entered the area of detection again stop the timer
	if body.name == "Player" and $PeriodOfMemory.get_time_left() > 0:
		$PeriodOfMemory.stop()
		
	if body.has_method("addedToSquad"):
		if not body.inSquad:
			addToSquad(body)
			
# For how long it can track a threat for once it is out of it's vision
func _on_PeriodOfMemory_timeout():
	if targetClear(): # of no part of the squad contains a reference to the target then clear it from memory
		update_squad_target(null)
		
func addToSquad(body):
	if body.has_method("projectile_hit"): 
		return
	if squad.find(body) == -1:
		if target:
			body.target = target
		if squad.size() < maxSquadTotal: # If there isn't too many already
			if body.has_method("grunt"):
				if gruntTotal < maxGruntTotal: # checks if there is too many grunts
					squad.append(body)
					gruntTotal += 1
			elif body.has_method("rat"):
				ratTotal += 1
				squad.append(body)
			if body.has_method("addedToSquad"):
				body.addedToSquad(self) #Tells squad members to follow the commander's orders
		
func _on_squad_members_death(deadMember):
	for i in range(0, squad.size()-1):
		if squad[i] == deadMember:
			squad.remove(i)
				
func calculateFollowPosition():
	var spot: Vector2 = self.velocity * -1 # get the negative velocity of the leader
	spot = spot.normalized() * BEHIND_LEADER_DIST # gets the direction and length of one to times it by the distance we want
	return spot + self.position
	
# Updates the squad blackboard on what and where the target is
func update_squad_target(body):
	target = body
	blackboard.set("target", target, behaviourTree, self)
	
	for member in squad:
		if is_instance_valid(member) and member.has_method("is_enemy"):
			member.target = target

func targetClear():
	# Is target clear from squad?
	var targetClear = true
	for member in squad:
		if is_instance_valid(member) and member.has_method("is_enemy"):
			if member.target:
				targetClear = false
	return targetClear
	
func death():
	for member in squad:
		if is_instance_valid(member) and member.has_method("is_enemy"):
			member.squadDisbanded()
			
	Global.update_enemy_death_count()
	
	target = null
	blackboard.set("target", target, behaviourTree, self)
	emit_signal("enemy_death", score_to_add)
	Global.largeEnemyCount -= 1
	queue_free()
