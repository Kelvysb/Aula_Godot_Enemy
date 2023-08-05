extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5
@onready var navigation_agent_3d = $NavigationAgent3D as NavigationAgent3D
@onready var space = get_viewport().world_3d.direct_space_state
@onready var vision = $Vision

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):	
	
	var target = getTarget()
	
	if target != Vector3.ZERO:
		navigation_agent_3d.set_target_position(target)
	
		
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var current_agent_position: Vector3 = global_position
	var new_velocity: Vector3 = (next_path_position - current_agent_position).normalized() * SPEED
	navigation_agent_3d.set_velocity(new_velocity.move_toward(new_velocity, .25))
	
	
	# Add the gravity.	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	
	FaceDirection(delta)
	move_and_slide()
	
	
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

