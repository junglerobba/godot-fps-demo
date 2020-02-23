extends Node

class_name Weapon

onready var raycast: RayCast = $"../Head/Camera/RayCast"
onready var ammo_label: Label = $"../HUD/Label"
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var audio_player: AudioStreamPlayer = $GunSound
onready var reload_audio_player: AudioStreamPlayer = $ReloadSound

export var fire_rate: float = 0.6
export var clip_size: int = 15
export var reload_rate: float = 1.5
export var damage: float = 1.0

var current_ammo: int
var can_fire: bool = true
var reloading: bool = false

func set_ammo(ammo: int) -> void:
	current_ammo = ammo if ammo > -1 else clip_size

func _process(_delta: float) -> void:
	if reloading:
		ammo_label.set_text("Ammo\nReloading...")
	else:
		ammo_label.set_text("Ammo\n%d / %d" % [current_ammo, clip_size])

	if Input.is_action_pressed("primary_fire") && can_fire:
		if current_ammo > 0 && !reloading:
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
		print(collider)
		if collider.is_in_group("Enemies") \
		&& collider.has_method("hit"):
			collider.hit(damage)
		elif collider is Interactable:
			collider.interact()

func fire() -> void:
	animation_player.play("shoot")
	audio_player.play()
	can_fire = false
	current_ammo -= 1
	check_collision()
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

func reload() -> void:
	reloading = true
	reload_audio_player.play()
	yield(get_tree().create_timer(reload_rate), "timeout")
	current_ammo = clip_size
	reloading = false

