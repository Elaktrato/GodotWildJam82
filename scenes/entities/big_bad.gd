extends CharacterBody3D

@export var navigation_agent: NavigationAgent3D
@export var random_range: float = 7.0
@export var _eye: Node3D
@export var _memory: Area3D
@export_flags_3d_physics var raycast_collision_mask: int

const SPEED = 2.0
const JUMP_VELOCITY = 4.5

var _follow_body: Node3D
var _chasing: bool = false
var _reposition_timer: Timer


func _enter_tree() -> void:
	_reposition_timer = Timer.new()
	add_child(_reposition_timer)


func _ready() -> void:
	_reposition_timer.connect("timeout", _on_reposition_timeout)
	_reposition_timer.one_shot = false
	_reposition_timer.start(4.0)
	_on_reposition_timeout()


func _physics_process(delta: float) -> void:
	var destination: Vector3 = navigation_agent.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := (destination - global_position).normalized()
	var direction := (Vector3(input_dir.x, 0, input_dir.z)).normalized()
	if direction && global_position.distance_squared_to(destination) > 1.0:
		look_at(global_position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _raycast(target: Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(_eye.global_position, target, raycast_collision_mask)
	return space_state.intersect_ray(query)


func _is_target_visible(target: Vector3) -> bool:
	return _raycast(target).is_empty()


func _on_line_of_sight_body_entered(body: Node3D) -> void:
	if body.is_in_group("players") && _is_target_visible(body.global_position):
		_follow_body = body
		_chasing = true
		_reposition_timer.start(4.0)
		print("Found!")
		_on_reposition_timeout()


func _on_line_of_sight_body_exited(body: Node3D) -> void:
	if body == _follow_body:
		#_follow_body = null
		#_chasing = false
		#print("Out of sight.")
		#_reposition_timer.start(8.0)
		pass


func _on_reposition_timeout() -> void:
	if _follow_body && !_is_target_visible(_follow_body.global_position) && !_memory.overlaps_body(_follow_body):
		_follow_body = null
		_chasing = false
		print("Blocked off!")
	_set_target_position()


func _set_target_position() -> void:
	if _follow_body:
		navigation_agent.target_position = _follow_body.global_position
		if !_is_target_visible(_follow_body.global_position) && _memory.overlaps_body(_follow_body):
			_reposition_timer.start(8.0)
		else:
			_reposition_timer.start(0.25)
	else:
		var p = Vector3.ZERO
		p.x = randf_range(-random_range, random_range)
		p.z = randf_range(-random_range, random_range)
		navigation_agent.target_position = p
		_reposition_timer.start(4.0)
