extends CharacterBody3D

class_name Player

const SPEED = 3.0


const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.01


@onready var vida = $Control/Vida

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var maxHp: int = 10
@onready var hp : int = maxHp 
@onready var tela_dano = $Control/TelaDano

@onready var pivot = $Pivot
@onready var camera = $Pivot/Camera3D

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot.rotate_y(-(event as InputEventMouseMotion).relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-(event as InputEventMouseMotion).relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta):
	vida.text = str(hp)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func LevarDano(dano : int):
	hp = hp - dano
	if hp <= 0:
		get_tree().quit()
	var tween = get_tree().create_tween()
	tela_dano.modulate = Color(1,0,0,0.8)
	tween.tween_property(tela_dano, "modulate", Color(1,0,0,0), 0.5)
