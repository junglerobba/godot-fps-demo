extends Weapon

export var fire_range: float = 200

func _ready() -> void:
	raycast.cast_to = Vector3(0, 0, -fire_range)
