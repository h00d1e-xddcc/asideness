extends CharacterBody3D
class_name asideness_user

@export var speed = 5.0
@export var mouse_sensitivity = 0.002

@export var head : Node3D

func _ready() :
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta): # Гравитация 
	if not is_on_floor(): velocity.y -= 9.8 * delta
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	var direction := (transform.basis * Vector3(input.x, 0, input.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Поворот тела влево/вправо
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Поворот головы вверх/вниз
		head.rotate_x(-event.relative.y * mouse_sensitivity)

		# Ограничиваем вертикальный обзор
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89.0),deg_to_rad(89.0))
