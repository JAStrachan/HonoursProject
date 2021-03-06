extends Node

# Deals with how many enemies spawn and when they spawn

var MediumEnemy = preload("res://Enemies/MediumEnemy.tscn")
var SmallEnemy = preload("res://Enemies/SmallEnemy.tscn")
var LargeEnemy = preload("res://Enemies/LargeEnemy.tscn")

var HealthBoost = preload("res://powerups/HealthBoost.tscn")

var spawnableLocations

export (int) var Maximum_No_Of_Enemies = 15

func _ready():
	_on_ready()
	spawnableLocations = $TileMap.getSpawnLocations()
	spawnEnemies()
	spawnHealth()
	
# A method for the children of Map.gd to insert their own values
func _on_ready():
	pass
	
func spawnEnemies():
	var enemy = chooseEnemyToSpawn()
	if not enemy:
		return

	spawn(enemy, 0)
	$EnemySpawnTimer.start()
	
func spawnHealth():
	var healthBoost = HealthBoost.instance()
	
	spawn(healthBoost, -3)
	$HealthBoostTimer.start()
	
# Will Spawn an object,  trys modifer will determine how many trys it will take depending on number of spawn locations
func spawn(objectToSpawn, trysModifier):
	var spawned = false
	var noOfTrys = 0
	var maxNoOfTrys = spawnableLocations.size() + trysModifier
	while noOfTrys < maxNoOfTrys and spawned == false:
		noOfTrys += 1
		randomize()
		var random_number = rand_range(0, spawnableLocations.size()-1)
		random_number = round(random_number)
		# to get it in the center of the spawning tile
		var spawnLocation = Vector2(spawnableLocations[random_number].x + 16, spawnableLocations[random_number].y + 16)
		var listOfObjectPositions = getListOfObjectPositions()
		if isLocationClear(spawnLocation, listOfObjectPositions):
			objectToSpawn.spawn(spawnLocation)
			add_child(objectToSpawn)
			
			spawned = true
	
# Chooses what enemy to spawn depending on ratios of enemies alive
func chooseEnemyToSpawn():
	var enemy
	
	var largeEnemyCount = Global.largeEnemyCount
	var mediumEnemyCount = Global.mediumEnemyCount
	var smallEnemyCount = Global.smallEnemyCount
	var totalEnemyCount = largeEnemyCount + mediumEnemyCount + smallEnemyCount
	
	var ratioLarge = calculate_ratio(totalEnemyCount, largeEnemyCount)
	var ratioSmall = calculate_ratio(totalEnemyCount, smallEnemyCount)
	# I do not care so much about the ratio of the medium enemies
	
	# Calculating ratios to make sure the player isn't overwhelemed with large enemies
	
	# making sure there isnt more than 40% of enemies being large
	if ratioLarge > 40:
		if ratioSmall < 40:
			enemy = instanceEnemy(SmallEnemy)
		else:
			if randf() < 0.5:
				enemy = instanceEnemy(SmallEnemy)
			else:
				enemy = instanceEnemy(MediumEnemy)
	else:
		# If there isn't large number of large enemies, randomise spawn
		var randomFloat = randf()
		if randomFloat < 0.20:
			enemy = instanceEnemy(LargeEnemy)
		elif randomFloat < 0.60:
			enemy = instanceEnemy(MediumEnemy)
		else:
			enemy = instanceEnemy(SmallEnemy)
			
	return enemy
		
# The ratios of the enemy types on the map
func calculate_ratio(total, count):
	var ratio
	if count <= 0:
		ratio = 0
	else:
		ratio = count / total * 100
	return ratio
	
func instanceEnemy(enemy):
	# instances an enemy and keeps track of how many have been spawned
	enemy = enemy.instance()
	
	return enemy
	
# Testing to see if the location is clear to spawn enemies
func isLocationClear(location: Vector2, listOfObjectPositions):
	var clear = false
	for position in listOfObjectPositions:
		# Is there a object within 32 pixels of the middle of the tile
		if position.x < location.x + 32 and position.y < location.y + 32 and position.x > location.x - 32 and position.y > location.y - 32:
			return false
		else:
			clear = true
	return clear
	
# The list of objects that block the enemy spawning and their positions
func getListOfObjectPositions():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var healthBoosts = get_tree().get_nodes_in_group("HealthBoost")
	
	var listOfObjectPositions = Array()
	for index in range(0,enemies.size()):
		listOfObjectPositions.append(enemies[index].position) 
	for index in range(0,healthBoosts.size()):
		listOfObjectPositions.append(healthBoosts[index].position) 
	listOfObjectPositions.append($Player.position)
	return listOfObjectPositions

# On this timeout spawn a new enemy if the total number of enemies doesn't exceed the maximum
func _on_SpawnTimer_timeout():
	if getTotalNoOfEnemies() < Maximum_No_Of_Enemies:
		spawnEnemies()
		
func _on_HealthBoostTimer_timeout():
	var noOfHealthBoosts = get_tree().get_nodes_in_group("HealthBoost").size()
	if noOfHealthBoosts < 2:
		spawnHealth()

func getTotalNoOfEnemies():
	return Global.largeEnemyCount + Global.mediumEnemyCount + Global.smallEnemyCount



