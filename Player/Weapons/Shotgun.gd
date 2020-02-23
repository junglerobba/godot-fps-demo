extends Weapon

export var fire_range: float = 10

export var spread = 10
export var number_of_pellets = 8

func _ready() -> void:
	raycast.cast_to = Vector3(0, 0, -fire_range)

func fire() -> void:
	animation_player.play("shoot")
	audio_player.play()
	can_fire = false
	current_ammo -= 1
	var colliders = []
	var number_of_hits = []
	for i in range(number_of_pellets):
		var random_spread = Vector3(rand_range(-spread, spread), rand_range(-spread, spread), 0)
		var result: = check_pellet_collision(colliders, number_of_hits)
		colliders = result[0]
		number_of_hits = result[1]
		raycast.force_raycast_update()
	deal_damage(colliders, number_of_hits)
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

func check_pellet_collision(colliders: Array, number_of_hits: Array) -> Array:
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		var index: int = -1
		for i in range(len(colliders)):
			if colliders[i].get_instance_id() == collider.get_instance_id():
				index = i
				break
		if index >= 0:
			number_of_hits[index] += 1
		else:
			colliders.append(collider)
			number_of_hits.append(1)
	return [
		colliders,
		number_of_hits
	]

func deal_damage(colliders: Array, number_of_hits: Array) -> void:
	for i in range (len(colliders)):
		var collider = colliders[i]
		if collider.is_in_group("Enemies") \
		&& collider.has_method("hit"):
			collider.hit(number_of_hits[i] * damage)
		elif collider is Interactable:
			collider.interact()
