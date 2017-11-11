extends Node2D

export var jump_force = Vector2(0,-450)
export var move_force = Vector2(150, 0)
export var max_horizontal_velocity = 200
export var max_vertical_velocity = 450
export var lives = 1
export var feet_distance = 20

var should_shoot        = false
var jump_button_pressed = false



onready var body     = get_node("body")

signal entered_goal


func _ready():
	set_process_input(true)
	set_fixed_process(true)
	body.connect("body_enter", self, "_body_enter")
	pass

func _input(event):
	if event.is_action_pressed("shoot"):
		should_shoot = true
	if event.is_action_pressed("jump"):
		jump_button_pressed = true

func shoot():
	var space_state = get_world_2d().get_direct_space_state()
	# use global coordinates, not local to node
	var result = space_state.intersect_ray( body.get_global_pos(), get_global_mouse_pos(), get_parent().laser_ignore_objects)
	# deal with left and right movement
	if (not result.empty()):
		print("Hit at point: ",result.position)
		get_parent().draw_debug_circle(result.position)
		if result.collider.is_in_group("enemy_hit_zones"):
			var enemy_hit = result.collider
			get_parent().player_hit_enemy(enemy_hit.get_parent())
	should_shoot = false;
	
func _fixed_process(delta):
	
	feet_distance = max_horizontal_velocity * 0.2;
	if jump_button_pressed:
		attempt_jump()
	if should_shoot:
		shoot()
	if Input.is_action_pressed("move_left"):
		addxvel(-max_horizontal_velocity)
	elif Input.is_action_pressed("move_right"):
		addxvel(max_horizontal_velocity)
	else:
		setxvel(0)
	
	
	pass
	

func attempt_jump():
	var space_state = get_world_2d().get_direct_space_state()
	# use global coordinates, not local to node
	var player_pos = body.get_global_pos()
	var feet_pos = body.get_global_pos() + Vector2(0,feet_distance)
	var result = space_state.intersect_ray( player_pos, feet_pos, [self])
	# deal with left and right movement
	if (not result.empty()):
		print("Hit at point: ",result.position)
		get_parent().draw_debug_circle(result.position)
		if result.collider.is_in_group("jump_surfaces"):
			jump()
	jump_button_pressed = false

func jump():
	body.set_linear_velocity(body.get_linear_velocity() + Vector2(0,-max_vertical_velocity))

func _body_enter(other_body):
	if other_body.is_in_group("enemies"):
		get_parent().enemy_hit_player()
	if other_body.is_in_group("goals"):
		emit_signal("entered_goal", self)

# add x velocity
func addxvel(amount):
	var current_vel = body.get_linear_velocity()
	var current_y_vel = current_vel.y
	var new_vel = current_vel + Vector2(amount,0)
	new_vel.x = clamp(new_vel.x,-max_horizontal_velocity, max_horizontal_velocity)
	body.set_linear_velocity(new_vel)

# add y velocity
func addyvel(amount):
	var current_vel = body.get_linear_velocity()
	var current_x_vel = current_vel.x
	var new_vel = current_vel + Vector2(0,amount)
	new_vel.y = clamp(new_vel.y,-max_vertical_velocity, max_vertical_velocity)
	body.set_linear_velocity(new_vel)
	
# set x velocity
func setxvel(amount):
	body.set_linear_velocity(Vector2(amount,body.get_linear_velocity().y))
