extends CharacterBody3D

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
const PURSUIT_SPEED = 5.0
@onready var velocidade = SPEED
@onready var navigation_agent_3d = $NavigationAgent3D as NavigationAgent3D
@onready var space = get_viewport().world_3d.direct_space_state
@onready var vision = $Vision
@onready var timer = $Timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum estado {
	Andando,
	Seguindo,
	Atacando
}

var estado_atual : estado = estado.Andando

func _physics_process(delta):	
	
	var target = getTarget()
	if target != Vector3.ZERO:
		if target.distance_to(global_position) < 2:
			estado_atual = estado.Atacando
		else:
			estado_atual = estado.Seguindo
	else:
		estado_atual = estado.Andando
	
	match estado_atual:
		estado.Andando :
			ExecutarAndando()
		estado.Seguindo :
			ExecutarSeguindo(target)
		estado.Atacando :
			ExecutarAtacando(target)

	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var current_agent_position: Vector3 = global_position
	var new_velocity: Vector3 = (next_path_position - current_agent_position).normalized() * velocidade
	navigation_agent_3d.set_velocity(new_velocity.move_toward(new_velocity, .25))
	
	
	# Add the gravity.	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	
	FaceDirection(delta)
	move_and_slide()
	
func ExecutarAndando():
	velocidade = SPEED	
	print_debug("Estado : Andando")
	if(navigation_agent_3d.is_navigation_finished()):
		var target = get_tree().get_nodes_in_group("alvos").pick_random().global_position
		navigation_agent_3d.set_target_position(target)
	
func ExecutarSeguindo(target : Vector3):
	velocidade = PURSUIT_SPEED
	print_debug("Estado : Segindo")
	navigation_agent_3d.set_target_position(target)
	
	
func ExecutarAtacando(target : Vector3):
	print_debug("Estado : Atacando")
	navigation_agent_3d.set_target_position(target)
	if timer.is_stopped():
		timer.start()
		
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if not is_on_floor():
		velocity.y -= gravity
	velocity = safe_velocity.move_toward(safe_velocity, .25)
	FaceDirection()
	move_and_slide()


func getTarget()->Vector3:
	var bodies = vision.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player"):
			var query = PhysicsRayQueryParameters3D.create(global_transform.origin, body.global_transform.origin)
			query.exclude = [self]
			var cast = space.intersect_ray(query)
			if cast:
				var collider = cast.get("collider")
				if collider == body:
					return body.global_position

	return Vector3.ZERO
	
func FaceDirection(delta = 1):
	if Vector3(velocity.x, 0, velocity.z) == Vector3.ZERO:
		return
	var originalRot = rotation.y
	look_at(transform.origin + Vector3(velocity.x, 0, velocity.z))
	rotation.y = lerp_angle(originalRot, rotation.y, delta * .5)

func _on_timer_timeout():
	if estado_atual != estado.Atacando:
		timer.stop()
		return
	var player = get_tree().get_first_node_in_group("player") as Player
	player.LevarDano(1) 
