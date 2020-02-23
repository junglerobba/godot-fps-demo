extends KinematicBody

const MOVE_SPEED: int = 3
const GRAVITY: float = 0.98
const DESPAWN_TIMER: float = 10.0
const ATTACK_RANGE: float = 6.0
const ATTACK_INTERVAL: float = 2.0
const ATTACK_DAMAGE: float = 10.0

var speed: int = MOVE_SPEED

onready var raycast: RayCast = $RayCast
onready var anim_player: AnimationPlayer = $AnimationPlayer

var player: Player = null
var dead: bool = false
var health: float = 3.0
var flinching: bool = false
var attacking: bool = false

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
	raycast.cast_to = vec_to_player * ATTACK_RANGE
	
	move_and_collide(vec_to_player * speed * delta)
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider != null && collider == player:
			attack()

func walk() -> void:
	if !dead:
		speed = MOVE_SPEED
		anim_player.play("walk")

func hit(damage: float) -> void:
	speed = 0
	health -= damage
	if health > 0 && !flinching:
		flinching = true
		anim_player.play("hit")
		$DamageAudioPlayer.play()
		yield(anim_player, "animation_finished")
		flinching = false
		walk()
	elif health <= 0:
		kill()

func kill() -> void:
	dead = true
	$CollisionShape.disabled = true
	$DeathAudioPlayer.play()
	anim_player.play("die")
	yield(get_tree().create_timer(DESPAWN_TIMER), "timeout")
	queue_free()

func set_player(player: Player):
	self.player = player

func attack() -> void:
	if !attacking:
		attacking = true
		speed = 0
		player.hit(ATTACK_DAMAGE)
		yield(get_tree().create_timer(ATTACK_INTERVAL), "timeout")
		attacking = false
		speed = MOVE_SPEED
