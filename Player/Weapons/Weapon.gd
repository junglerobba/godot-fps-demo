extends Node

class_name Weapon

onready var raycast: RayCast = $"../../Head/Camera/RayCast"
onready var ammo_label: Label = $"../../HUD/AmmoLabel"
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var audio_player: AudioStreamPlayer = $GunSound
onready var reload_audio_player: AudioStreamPlayer = $ReloadSound
onready var empty_audio_player: AudioStreamPlayer = $EmptySound

export var fire_rate: float = 0.6
export var clip_size: int = 15
export var reload_rate: float = 1.5
export var damage: float = 1.0
export var fire_range: int = 200
export var automatic: bool = false

var current_ammo: int
var reserve_ammo: int
var can_fire: bool = false
var reloading: bool = false

func on_ready() -> void:
	can_fire = true

func _ready() -> void:
	animation_player.play("ready")
	raycast.cast_to = Vector3(0, 0, -fire_range)

func set_ammo(magazine: int, reserve: int) -> void:
	current_ammo = magazine if magazine > -1 else clip_size
	reserve_ammo = reserve

func _process(_delta: float) -> void:
	if clip_size == -1:
		ammo_label.set_visible(false)
	else:
		ammo_label.set_visible(true)
	if reloading:
		ammo_label.set_text("Ammo\nReloading...")
	else:
		ammo_label.set_text("Ammo\n%d / %s" % [current_ammo, (str(reserve_ammo) if (reserve_ammo > -1) else "-")])

	if Input.is_action_just_pressed("fire_primary") \
	&& current_ammo == 0 && reserve_ammo == 0:
		empty_audio_player.play()
		return

	if ((automatic && Input.is_action_pressed("fire_primary")) \
	|| (!automatic && Input.is_action_just_pressed("fire_primary"))) \
	&& can_fire:
		if (current_ammo > 0 && !reloading) || clip_size == -1:
			fire()
		elif !reloading:
			reload()

	if Input.is_action_just_pressed("reload") \
	&& !reloading \
	&& can_fire:
		reload()

func check_collision() -> void:
	if raycast.is_colliding():
		var collider: Object = raycast.get_collider()
		if collider.is_in_group("Enemies") \
		&& collider.has_method("hit"):
			collider.hit(damage)
		elif collider is Interactable:
			collider.interact()

func fire() -> void:
	animation_player.play("shoot")
	audio_player.play()
	can_fire = false
	if !clip_size == -1:
		current_ammo -= 1
	check_collision()
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

func reload() -> void:
	if clip_size == -1 \
	|| current_ammo == clip_size \
	|| reserve_ammo == 0:
		return
	reloading = true
	reload_audio_player.play()
	yield(get_tree().create_timer(reload_rate), "timeout")
	var ammo_remaining = current_ammo
	current_ammo = clip_size if \
		reserve_ammo >= clip_size \
		|| reserve_ammo == -1 \
		|| (reserve_ammo + ammo_remaining) >= clip_size \
		else reserve_ammo + ammo_remaining
	if reserve_ammo != -1:
		reserve_ammo -= current_ammo - ammo_remaining
	reloading = false

