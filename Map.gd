extends Node

# Deals with how many enemies spawn and when they spawn

var MediumEnemy = preload("res://Enemies/MediumEnemy.tscn")
var SmallEnemy = preload("res://Enemies/SmallEnemy.tscn")
var LargeEnemy = preload("res://Enemies/LargeEnemy.tscn")

var spawnableLocations


func _ready():
	spawnableLocations = $TileMap.getSpawnLocations()
	spawnEnemies(spawnableLocations)
	
func spawnEnemies(spawnableLocations):
	pass
#	var enemy = chooseEnemyToSpawn()
#	if not enemy:
#		return
#
#	var spawned = false
#	var noOfTrys = 0
#	while noOfTrys < spawnableLocations.size() and spawned == false:
#		noOfTrys += 1
#		randomize()
#		var random_number = rand_range(0, spawnableLocations.size()-1)
#		random_number = round(random_number)
#		# to get it in the center of the spawning tile
#		var spawnLocation = Vector2(spawnableLocations[random_number].x + 16, spawnableLocations[random_number].y + 16)
#		var listOfObjectPositions = getListOfObjectPositions()
#		if isLocationIsClear(spawnLocation, listOfObjectPositions):
#			enemy.spawn(spawnLocation)
#			add_child(enemy)
#			spawned = true
#	$SpawnTimer.start()
	
func chooseEnemyToSpawn():
	var enemy
	
	var largeEnemyCount = Global.largeEnemyCount
	var mediumEnemyCount = Global.mediumEnemyCount
	var smallEnemyCount = Global.smallEnemyCount
	var totalEnemyCount = largeEnemyCount + mediumEnemyCount + smallEnemyCount
	
	var ratioLarge = calculate_ratio(totalEnemyCount, largeEnemyCount)
	var ratioMedium = calculate_ratio(totalEnemyCount, mediumEnemyCount)
	var ratioSmall = calculate_ratio(totalEnemyCount, smallEnemyCount)
	
	# Calculating ratios to make sure the player isn't overwhelemed with large enemies
	
	if ratioLarge > 40:
		if ratioSmall < 40:
			enemy = instanceEnemy(SmallEnemy)
		else:
			if randf() < 0.5:
				enemy = instanceEnemy(SmallEnemy)
			else:
				enemy = instanceEnemy(MediumEnemy)
	else:
		var randomFloat = randf()
		if randomFloat < 0.34:
			enemy = instanceEnemy(LargeEnemy)
		elif randomFloat < 0.67:
			enemy = instanceEnemy(MediumEnemy)
		else:
			enemy = instanceEnemy(SmallEnemy)
			
	return enemy
		
func calculate_ratio(total, count):
	var ratio
	if count == 0:
		ratio = 0
	else:
		ratio = total/count * 100
	return ratio
	
func instanceEnemy(enemy):
	# instances an enemy and keeps track of how many have been spawned
	enemy = enemy.instance()
	
	var enemyClass = enemy.get_class()
	
	if enemyClass == "SmallEnemy":
		Global.smallEnemyCount += 1
	elif enemyClass == "MediumEnemy":
		Global.mediumEnemyCount += 1
	elif enemyClass == "LargeEnemy":
		Global.largeEnemyCount += 1
	
	return enemy
	
func isLocationIsClear(location: Vector2, listOfObjectPositions):
	var clear = false
	for position in listOfObjectPositions:
		# Is there a object within 32 pixels of the middle of the tile
		if position.x < location.x + 32 and position.y < location.y + 32 and position.x > location.x - 32 and position.y > location.y - 32:
			return false
		else:
			clear = true
	return clear
	
func getListOfObjectPositions():
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	var listOfObjctPositions = Array()
	for index in range(0,enemies.size()):
		listOfObjctPositions.append(enemies[index].position) 
	listOfObjctPositions.append($Player.position)
	return listOfObjctPositions

func _on_SpawnTimer_timeout():
	spawnEnemies(spawnableLocations)
