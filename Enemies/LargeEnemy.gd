extends "res://Enemies/Enemy.gd"

func _ready():
	behaviourTree = get_node('/root/Map/LargeEnemyTree')