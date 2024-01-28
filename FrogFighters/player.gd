extends CharacterBody2D

@export_enum("1", "2") var player_number: String

const SPEED = 50.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("player" + player_number + "_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move
	var direction = Input.get_axis("player" + player_number + "_left", "player" + player_number + "_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# Pick animation
	if is_on_floor():
		if direction:
			$AnimatedSprite2D.play("shuffle")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")

	move_and_slide()
