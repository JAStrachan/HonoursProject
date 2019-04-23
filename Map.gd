extends Node

# Deals with how many enemies spawn and when they spawn

var MediumEnemy = preload("res://Enemies/BasicEnemy.tscn")
var SmallEnemy = preload("res://Enemies/SmallEnemy.tscn")
var LargeEnemy = preload("res://Enemies/LargeEnemy.tscn")

var spawnableLocations

func _ready():
	spawnableLocations = $TileMap.getSpawnLocations()
	#spawnEnemies(spawnableLocations)
	
func spawnEnemies(spawnableLocations):
	var mediumEnemy = MediumEnemy.instance()
	#var SmallEnemy = SmallEnemy.instance()
	#var LargeEnemy = LargeEnemy.instance()
	
	# to get it in the center of the spawning tile
	var spawnLocation = Vector2(spawnableLocations[0].x + 16, spawnableLocations[0].y + 16)
	var listOfObjectPositions = getListOfObjectPositions()
	if isLocationIsClear(spawnLocation, listOfObjectPositions):
		mediumEnemy.spawn(spawnLocation)
		self.add_child(mediumEnemy)
	
	$SpawnTimer.start()
	
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
