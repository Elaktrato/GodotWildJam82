extends CharacterBody3D

var _walkingAcceleration: float = 35.0
var _walkingSpeedCap: float = 1.0
var _walkingDeceleration: float = 7.0
var _walkingAirAcceleration: float = 20.0
var _drag: float = .15
var _jumpVelocity: float = 7.50
var _jumpForwardVelocity: float = 1.0
var _gravity: float = 20.0
@onready var _head: Node3D = $Head

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _wishDir: Vector3
var _jumpDirection: Vector2
var _disable_mouse_capture: bool = false

var _wishDirXZ: Vector2:
	get:
		return Vector2(_wishDir.x, _wishDir.z)
	set(v):
		_wishDir.x = v.x
		_wishDir.z = v.y

var _velocityXZ: Vector2:
	get:
		return Vector2(velocity.x, velocity.z)
	set(v):
		velocity.x = v.x
		velocity.z = v.y


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	# Get the wish direction. This will come to play on the physics thread
	_set_wish_direction()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if !_disable_mouse_capture else Input.MOUSE_MODE_CAPTURED
			_disable_mouse_capture = !_disable_mouse_capture

	if event is InputEventMouseMotion && !_disable_mouse_capture:
		var mv: Vector2 = event.relative * 0.005
		rotate_y(-mv.x)
		_head.rotate_x(-mv.y)
		_head.rotation.x = clamp(_head.rotation.x, -4.0 / PI, 4.0 / PI)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		_process_midair(delta)
	else:
		_process_ground(delta)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		_jump_impulse()

	# Handle movement in the wish direction
	_process_movement(delta)

	move_and_slide()


func _process_midair(delta: float) -> void:
	# Handle gravity
	velocity.y -= _gravity * delta;
	velocity.y = lerp(velocity.y, 0.0, _drag * delta);


func _process_ground(delta: float) -> void:
	# Handle friction
	_jumpDirection = Vector2.ZERO;
	_velocityXZ = _velocityXZ.lerp(Vector2.ZERO, (_walkingDeceleration) * delta);


func _set_wish_direction() -> void:
	var inputDir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	_wishDir = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized();


func _process_movement(delta: float, speedMultiplier: float = 1.0, speedOffset: float = 0.0) -> void:
	# Handle acceleration
	#  Only if the player is moving slower than the speed cap or holding any direction
	#  other than forward.
	var speedCap = (_walkingSpeedCap + speedOffset) * speedMultiplier

	if (_velocityXZ.length() < speedCap + _jumpForwardVelocity || _velocityXZ.normalized().dot(_wishDirXZ) <= 0.5): 
		# jumpDirDot is the dot product of the velocity direction and the wish direction
		#  It lets the player move backwards in the air after jumping in a direction
		var jumpDirDot: float = clamp((-_velocityXZ.normalized().dot(_wishDirXZ) + 1.0) / 2.0, 0.375, 1.0) if _jumpDirection.is_zero_approx() else 0.375;
		# Different accelearation rates in the air and on the ground
		#  Mid air acceleration is affected by jumpDirDot^2
		var acceleration: float = _walkingAcceleration if is_on_floor() else _walkingAirAcceleration * jumpDirDot
		_velocityXZ += _wishDirXZ * acceleration * delta
	

func _jump_impulse(yFactor: float = 1.0, xzFactor: float = 1.0) -> void:
	velocity.y = _jumpVelocity * yFactor;
	_jumpDirection = _wishDirXZ;
	var speedCap = _walkingSpeedCap;
	if (is_on_floor()):
		# Add the jump forward velocity to the current velocity on the ground
		_velocityXZ += _wishDirXZ * _jumpForwardVelocity * xzFactor;
	else:
		# Set the velocity to the walking speed cap + the jump forward velocity in mid air
		_velocityXZ = _wishDirXZ * speedCap * xzFactor;
	
	#_jumps++;
	#_isJumping = true;
