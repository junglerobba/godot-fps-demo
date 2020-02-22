extends KinematicBody

export var speed: int = 10
export var acceleration: int = 5
export var gravity: float = 0.98
export var jump_power: int = 30
export var mouse_sensitivity: float = 0.3

onready var head: Spatial = $Head
onready var camera: Camera = $Head/Camera

var velocity: = Vector3()
var camera_x_rotation: float = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y -= gravity

	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y += jump_power

	velocity = move_and_slide(velocity, Vector3.UP)