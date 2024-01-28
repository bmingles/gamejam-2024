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

var audio_clips
const audio_delay = {
	"fish": .2,
	"chicken": 1.2
}

func _ready():
	audio_clips = {
		"laugh": preload("res://assets/audio/laugh.mp3"),
		"chicken": preload("res://assets/audio/chicken.mp3"),
		"fish": preload("res://assets/audio/fish.mp3"),
		"jump": preload("res://assets/audio/jump.mp3")
	}
	
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
		play_audio("jump")

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
	toggle_taking_damage(0)

func toggle_attack(value: String):
	is_attacking = value
	if is_attacking:
		await get_tree().create_timer(.2).timeout
		$HitBox/CollisionShape2D.disabled = false
	else:
		$HitBox/CollisionShape2D.disabled = true
			
	if is_attacking:
		$AnimatedSprite2D.play(value)
		play_audio(value)
		
func toggle_taking_damage(value: int):
	toggle_attack("")
	is_taking_damage = value
	if value:
		# TODO: tie to get_audio_delay() but need way to know which attack is hitting
		await get_tree().create_timer(.2).timeout
		
		$AnimatedSprite2D.play("laugh")
		$AnimatedSprite2D/AnimationPlayer.play("hit_animation")
		play_audio("laugh")
		health_bar.take_damage(value)

func get_audio_delay(clip_name: String):
	return audio_delay[clip_name] if audio_delay.has(clip_name) else 0
		
func play_audio(clip_name: String):
	$SoundEffect.stream = audio_clips[clip_name]
	await get_tree().create_timer(get_audio_delay(clip_name)).timeout
	$SoundEffect.play()

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

	toggle_taking_damage(amount)
