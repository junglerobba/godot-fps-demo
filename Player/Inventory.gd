extends Node

var weapon: Weapon = null

var weapon_selected: int = 0
var weapons: Array = [
	{
		'weapon': load("res://Player/Weapons/Fists.tscn"),
		'ammo': -1
	},
	{
		'weapon': load("res://Player/Weapons/Pistol.tscn"),
		'ammo': -1
	},
	{
		'weapon': load("res://Player/Weapons/Shotgun.tscn"),
		'ammo': -1
	},
	{
		'weapon': load("res://Player/Weapons/SMG.tscn"),
		'ammo': -1
	}
]

func _ready() -> void:
	select_weapon(weapon_selected)

func _input(event: InputEvent) -> void:
	for i in range(len(weapons)):
		if Input.is_action_just_pressed("weapon_0%d" % (i + 1)):
			select_weapon(i)
	if Input.is_action_pressed("weapon_next"):
		select_weapon((weapon_selected + 1) % len(weapons))
	if Input.is_action_pressed("weapon_prev"):
		select_weapon((weapon_selected + len(weapons) - 1) % len(weapons))

func select_weapon(index: int) -> void:
	if !index >= len(weapons) && index >= 0:
		if weapon != null:
			weapons[weapon_selected].ammo = weapon.current_ammo
			remove_child(weapon)
			weapon = null
		weapon_selected = index
		weapon = weapons[index].weapon.instance()
		weapon.set_ammo(weapons[index].ammo)
		weapon.set_name("Weapon")
		add_child(weapon)
