extends KinematicBody2D

var velocity = Vector2()
export (int) var bullet_velocity = 400
export (int) var bullet_damage = 30

# adapted from https://docs.godotengine.org/en/latest/tutorials/physics/using_kinematic_body_2d.html
func spawn(pos, dir):
	rotation = dir
	position = pos
	velocity = Vector2(bullet_velocity, rotation).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.has_method("bullet_hit"):
			collision.collider.bullet_hit(bullet_damage)
			
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
