extends CharacterBody2D

const SPEED = 150.0
const ACCELERATION = 1500.0  # Acceleration rate
const DECELERATION = 800.0   # Deceleration rate
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var horizontal_velocity = 0.0  # Use a dedicated variable for horizontal movement

func _physics_process(delta):
	# Apply gravity manually if needed, or adjust the character's gravity scale
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		horizontal_velocity = move_toward(horizontal_velocity, direction * SPEED, ACCELERATION * delta)
	else:
		horizontal_velocity = move_toward(horizontal_velocity, 0, DECELERATION * delta)

	if direction >= 1:
		$Sprite2D.flip_h = false;
	elif direction <= -1:
		$Sprite2D.flip_h = true;
	# Update the velocity vector
	velocity.x = horizontal_velocity

	# Move the character
	move_and_slide()
