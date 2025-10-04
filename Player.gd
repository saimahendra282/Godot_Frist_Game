extends KinematicBody2D

# --- Movement variables ---
var speed = 150           # horizontal speed
var jump_force = -300     # negative Y moves up
var gravity = 600         # pull down
var velocity = Vector2.ZERO
var can_double_jump = true

# --- References ---
onready var sprite = $AnimatedSprite

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	# --- Horizontal input ---
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_vector.x * speed

	# --- Gravity ---
	velocity.y += gravity * delta

	# --- Jump ---
	if is_on_floor():
		can_double_jump = true  # reset double jump when touching ground
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jump_force
			sprite.play("jump")
	elif Input.is_action_just_pressed("ui_up") and can_double_jump:
		velocity.y = jump_force
		can_double_jump = false
		sprite.play("double_jump")

	# --- Move player ---
	velocity = move_and_slide(velocity, Vector2.UP)

	# --- Animation handling ---
	if is_on_floor():
		if input_vector.x == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
			sprite.flip_h = input_vector.x < 0
	else:
		if velocity.y < 0:
			# Moving up
			if not can_double_jump:
				sprite.play("double_jump")
			else:
				sprite.play("jump")
		else:
			# Falling
			sprite.play("jump")  # fallback to jump animation while falling
