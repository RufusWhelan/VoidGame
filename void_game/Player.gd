extends CharacterBody2D

@onready var sprite = $Sprite

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dashing: bool = false

func _input(_event):
	if Input.is_action_just_pressed('primary_action'): dash()

func _physics_process(delta):
	if !dashing:
		if not is_on_floor():
			velocity.y += gravity * delta

		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			if is_on_floor(): velocity.x = move_toward(velocity.x, 0, SPEED)
			else: velocity.x = lerp(velocity.x, 0.0, 0.1)

	move_and_slide()

func _process(_delta):
	if Input.is_action_just_pressed('down'):
		if Globals.in_void: Globals.in_void = false
		else: Globals.in_void = true
		Globals.update_void_state.emit()
		
	#else: 

func dash():
	dashing = true
	Globals.in_void = true
	sprite.look_at(get_global_mouse_position())
	$DashTimer.start(0.2)
	$Sprite/NonVoid.visible = false
	$Sprite/Void.visible = true
	velocity = position.direction_to(get_global_mouse_position()) * 1000



func _on_dash_timer_timeout():
	$Sprite/NonVoid.visible = true
	$Sprite/Void.visible = false
	sprite.rotation = 0
	dashing = false
	Globals.in_void = false
	velocity.y = clamp(velocity.y, -400, 400)
