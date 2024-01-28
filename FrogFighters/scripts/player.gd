extends CharacterBody2D

@export_enum("1", "2") var player_number: String
@export var frames: Resource
@export var health_bar: HealthBar

const SPEED = 50.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: String = ""
var is_taking_damage = false

func _ready():
	toggle_attack("")

	if player_number == "2":
		var flip_h_offset = Vector2(-1, 0)
		$AnimatedSprite2D.set_flip_h(true)
		$AnimatedSprite2D.offset *= flip_h_offset
		$HitBox/CollisionShape2D.position *= flip_h_offset

	$AnimatedSprite2D.set_sprite_frames(frames)
	$AnimatedSprite2D.connect("animation_finished", _on_animation_finished)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("player" + player_number + "_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var actions = get_actions()

	# Move
	var direction = Input.get_axis("player" + player_number + "_left", "player" + player_number + "_right")
	if direction and is_attacking != "fish":
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	handle_animation(direction, actions)

	move_and_slide()


func _on_animation_finished():
	toggle_attack("")
	toggle_taking_damage(false)

func toggle_attack(value: String):
	is_attacking = value
	$HitBox/CollisionShape2D.disabled = !is_attacking
	if is_attacking:
		$AnimatedSprite2D.play(value)
		
func toggle_taking_damage(value: bool):
	toggle_attack("")
	is_taking_damage = value
	if value:
		$AnimatedSprite2D.play("laugh")
		$AnimatedSprite2D/AnimationPlayer.play("hit_animation")

func get_actions():
	return {
		"fish": Input.is_action_just_pressed("player" + player_number + "_fish"),
		"chicken": Input.is_action_just_pressed("player" + player_number + "_chicken"),
		"laugh": Input.is_action_just_pressed("player" + player_number + "_laugh")
	}

func handle_animation(direction: float, actions):
	# Pick animation
	if is_attacking or is_taking_damage:
		pass
	elif actions["fish"]:
		toggle_attack("fish")
	elif actions["laugh"]:
		toggle_attack("laugh")
	elif actions["chicken"]:
		toggle_attack("chicken")
	elif is_on_floor():
		if direction:
			$AnimatedSprite2D.play("shuffle")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")

func take_damage(amount: int):
	if health_bar == null:
		return

	health_bar.take_damage(amount)
	toggle_taking_damage(true)

