extends CharacterBody2D

#Allows to keep track of current player action
enum STATES {
IDLE,
RUNNING,
ATTACKING,
JUMPING,
FALLING
}

const SPEED: float = 150.0
const ACCELERATION: float = 1500.0  # Acceleration rate
const DECELERATION: float = 800.0   # Deceleration rate
const JUMP_VELOCITY: float = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var horizontal_velocity: float = 0.0  # Use a dedicated variable for horizontal movement
var state
#Attack state handler to disable movement during attack
var  input_locked: bool = false

#setup 
func _ready():
		$AnimationPlayer.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))
		$MeleeArea/MeleeBox.disabled = true

func _physics_process(delta):
	#handles attack freeze
	if input_locked == true:
		return
		
	# Apply gravity manually if needed, or adjust the character's gravity scale
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = STATES.JUMPING

	# Get input direction
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		horizontal_velocity = move_toward(horizontal_velocity, direction * SPEED, ACCELERATION * delta)
	else:
		horizontal_velocity = move_toward(horizontal_velocity, 0, DECELERATION * delta)

	if direction >= 1:
		$Sprite2D.flip_h = false;
		$MeleeArea/MeleeBox.position.x = -2 # MeleeBox to the right
	elif direction <= -1:
		$Sprite2D.flip_h = true;
		$MeleeArea/MeleeBox.position.x = -32 # MeleeBox to the right

	# Update the velocity vector
	velocity.x = horizontal_velocity
	# Move the character
	move_and_slide()
	
	#State machine
	#(Stops other inputs if attacking)
	if Input.is_action_just_pressed("attack") and state != STATES.ATTACKING:
		state = STATES.ATTACKING
		input_locked = true
		$AnimationPlayer.play("Attack")
		$MeleeArea/MeleeBox.disabled = false
	else:
		if horizontal_velocity == 0 and velocity.y == 0:
			state = STATES.IDLE
		elif horizontal_velocity != 0 and velocity.y == 0:
			state = STATES.RUNNING
		elif velocity.y >= 1:
			state = STATES.FALLING
		elif velocity.y <= -1:
			state = STATES.JUMPING
	
	#Anim Manager
	if state == STATES.IDLE:
		$AnimationPlayer.play("Idle")
	elif state == STATES.RUNNING:
		$AnimationPlayer.play("Run")
	elif state == STATES.FALLING:
		$AnimationPlayer.play("Fall")
	elif state == STATES.JUMPING:
		$AnimationPlayer.play("Jump")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		input_locked = false
		$MeleeArea/MeleeBox.disabled = true  # Disable collision detection


