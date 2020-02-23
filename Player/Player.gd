extends KinematicBody

class_name Player

export var speed: int = 10
export var sprint_speed: int = 20
export var crouch_speed: int = 3
export var acceleration: int = 5
export var gravity: float = 0.98
export var jump_power: int = 30
export var mouse_sensitivity: float = 0.1

onready var head: Spatial = $Head
onready var camera: Camera = $Head/Camera
onready var footstep: AudioStreamPlayer = $FootStep
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var crouch_raycast: RayCast = $"Head/CrouchRayCast"

var velocity: = Vector3()
var camera_x_rotation: float = 0
var crouched: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().call_group("Enemies", "set_player", self)

func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED \
	&& event is InputEventMouseButton \
	&& event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion \
	&& Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		var x_delta: float = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 && camera_x_rotation + x_delta < 90:
			camera.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			camera_x_rotation += x_delta

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	var head_basis: = head.get_global_transform().basis
	var direction: Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z

	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x

	direction = direction.normalized()

	var temp_speed: = speed
	
	if Input.is_action_pressed("move_crouch") || crouched:
		if is_on_floor():
			temp_speed = crouch_speed
		if !crouched:
			anim_player.play("crouch")
			crouched = true
	
	if !Input.is_action_pressed("move_crouch") && crouched:
		uncrouch()
	
	if Input.is_action_pressed("move_sprint"):
		if !crouched:
			temp_speed = sprint_speed

	velocity = velocity.linear_interpolate(direction * temp_speed, acceleration * delta)
	velocity.y -= gravity

	if Input.is_action_just_pressed("jump") \
	&& is_on_floor():
		velocity.y += jump_power

	if is_moving_on_floor(velocity) && \
	!footstep.playing:
		footstep.play()

	velocity = move_and_slide(velocity, Vector3.UP)

func uncrouch() -> void:
	if !crouch_raycast.is_colliding():
		anim_player.play_backwards("crouch")
		crouched = false

func is_moving_on_floor(velocity: Vector3) -> bool:
	return (velocity.x > 5 || velocity.x < -5 \
	|| velocity.z > 5 || velocity.z < -5) \
	&& is_on_floor()
