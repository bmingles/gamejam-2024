extends CharacterBody2D

@export_enum("1", "2") var player_number: String
@export var frames: Resource
@export var health_bar: HealthBar

const SPEED = 50.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false

func _ready():
	toggle_attack(false)
	
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

	# Move
	var direction = Input.get_axis("player" + player_number + "_left", "player" + player_number + "_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	handle_animation(direction)

	move_and_slide()


func _on_animation_finished():
	toggle_attack(false)
	
func toggle_attack(value: bool):
	is_attacking = value
	$HitBox/CollisionShape2D.disabled = !is_attacking

func handle_animation(direction: float):
	var is_fish = Input.is_action_just_pressed("player" + player_number + "_fish")
	var is_chicken = Input.is_action_just_pressed("player" + player_number + "_chicken")
	var is_laugh = Input.is_action_just_pressed("player" + player_number + "_laugh")
		
	# Pick animation
	if is_attacking:
		pass
	elif is_fish:
		toggle_attack(true)
		$AnimatedSprite2D.play('fish')
	elif is_laugh:
		toggle_attack(true)
		$AnimatedSprite2D.play('laugh')
	elif is_chicken:
		toggle_attack(true)
		$AnimatedSprite2D.play('chicken')
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
	
