extends KinematicBody2D

# --- Movement variables ---
var speed = 150            # horizontal speed
var jump_force = -300      # negative Y moves up
var gravity = 600          # pull down
var velocity = Vector2.ZERO
var can_double_jump = true
var direction = 0          # mobile input: -1 left, 1 right

# --- References ---
onready var sprite = $AnimatedSprite

func _physics_process(delta):
	# --- Horizontal movement ---
	var input_vector = Vector2.ZERO

	# Keyboard input
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# Add mobile input
	input_vector.x += direction

	velocity.x = input_vector.x * speed

	# --- Gravity ---
	velocity.y += gravity * delta

	# --- Jump ---
	if is_on_floor():
		can_double_jump = true
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
		if velocity.x == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
			sprite.flip_h = velocity.x < 0
	else:
		if velocity.y < 0:
			if not can_double_jump:
				sprite.play("double_jump")
			else:
				sprite.play("jump")
		else:
			sprite.play("jump")  # fallback while falling

# --- TouchScreenButton callbacks ---
func _on_LeftButton_pressed():
	direction = -1

func _on_LeftButton_released():
	if direction == -1:
		direction = 0

func _on_RightButton_pressed():
	direction = 1

func _on_RightButton_released():
	if direction == 1:
		direction = 0

func _on_JumpButton_pressed():
	if is_on_floor():
		velocity.y = jump_force
		sprite.play("jump")
	elif can_double_jump:
		velocity.y = jump_force
		can_double_jump = false
		sprite.play("double_jump")
func _on_JumpButton_released():
	# If player is moving upwards and releases jump early, reduce upward velocity
	if velocity.y < 0:
		velocity.y *= 0.5  # halve the upward velocity for a shorter jump
