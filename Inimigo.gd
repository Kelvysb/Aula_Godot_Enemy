extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 4.5
@onready var navigation_agent_3d = $NavigationAgent3D as NavigationAgent3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var target = (get_tree().get_first_node_in_group("player") as Node3D).global_position
	
	navigation_agent_3d.set_target_position(target)
	
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var current_agent_position: Vector3 = global_position
	var new_velocity: Vector3 = (next_path_position - current_agent_position).normalized() * SPEED
	navigation_agent_3d.set_velocity(new_velocity.move_toward(new_velocity, 0.25))
	look_at(target)
	
	move_and_slide()
	
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25) 
	move_and_slide()
