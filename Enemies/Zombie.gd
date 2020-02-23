extends KinematicBody

const MOVE_SPEED: int = 3
const GRAVITY: float = 0.98

var speed: int = MOVE_SPEED

onready var raycast: RayCast = $RayCast
onready var anim_player: AnimationPlayer = $AnimationPlayer

var player: Player = null
var dead: bool = false
var health: float = 3.0

func _ready() -> void:
	walk()
	add_to_group("Enemies")

func _physics_process(delta: float) -> void:
	if dead:
		return
	if player == null:
		return

	var vec_to_player = player.translation - translation
	vec_to_player = vec_to_player.normalized()
	vec_to_player.y = -GRAVITY
	raycast.cast_to = vec_to_player * 1.5

	move_and_collide(vec_to_player * speed * delta)

func walk() -> void:
	speed = MOVE_SPEED
	anim_player.play("walk")

func hit(damage: float) -> void:
	speed = 0
	health -= damage
	if health > 0:
		anim_player.play("hit")
		$DamageAudioPlayer.play()
		yield(anim_player, "animation_finished")
		walk()
	else:
		kill()

func kill() -> void:
	dead = true
	$CollisionShape.disabled = true
	$DeathAudioPlayer.play()
	anim_player.play("die")

func set_player(player: Player):
	self.player = player
