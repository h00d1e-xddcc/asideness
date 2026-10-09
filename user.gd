extends CharacterBody3D
class_name asideness_user

@export var console : Control
@export var speed = 5.0
@export var mouse_sensitivity = 0.002
@export var mouse : bool = false
@export var cfg : asideness_cfg

@onready var pty : PTY = $"../Terminal/PTY"
@onready var terminal : Terminal = $"../Terminal"
@onready var path_base = OS.get_environment("HOME")
@onready var path = path_base.path_join("/Desktop/asideness")
@onready var path_cfg = path.path_join("/cfg.tres")
#@onready var pipe_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/asideness/cfg_reload"
#var pipe_thread: Thread
#var is_listening: bool = true

@export var lvl : asideness_level
@export var head : Node3D

func _ready() :
	DirAccess.make_dir_recursive_absolute(path)
	print(path)
	print(FileAccess.file_exists(path))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_up()
	cfg_create()
	cfg_reload()

func _exit_tree() -> void: 
	OS.move_to_trash(path)

#region cfg
func cfg_create() :
	cfg = asideness_cfg.new()
	cfg.darkness = 255
	cfg.volume = 0.0
	cfg.mouse = 0.002
	ResourceSaver.save(cfg, path_cfg)

func cfg_reload() :
	await  get_tree().create_timer(.357).timeout
	var cfg_loaded = ResourceLoader.load(path_cfg) as asideness_cfg
	print(cfg_loaded.darkness)
	cfg.darkness = cfg_loaded.darkness
	cfg.mouse = cfg_loaded.mouse
	cfg.volume = cfg_loaded.volume
	$"../dark".color.a = cfg.darkness
	mouse = cfg.mouse
#endregion

#region user
func _physics_process(delta):
	if not is_on_floor(): velocity.y -= 9.8 * delta
	if Input.is_action_just_pressed("ui_cancel") : console.visible = !console.visible
	if Input.is_action_just_pressed("ui_undo") :
		match Input.mouse_mode :
			Input.MOUSE_MODE_CONFINED_HIDDEN :
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_ : Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
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
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89.0),deg_to_rad(89.0))
#endregion

#region terminal
func _on_terminal_size_changed(cols: int, rows: int):
	pty.resize(cols, rows)

func _on_terminal_data_sent(data: PackedByteArray) :
	var input_string = data.get_string_from_utf8()
	var input_clear = input_string.strip_edges()
#endregion

#region custom
func create_file(file_path : String, content : String, is_exec : bool = false) :
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(content)
	print(content)
	if is_exec : OS.execute("chmod", ["+x", file_path])
	file.close()

func set_up() :
	#pty.data_received.connect(terminal.write)
	#terminal.data_sent.connect(pty.write)
	pty.fork("/usr/bin/bash", ["-l"])
	terminal.size_changed.connect(_on_terminal_size_changed)
	_on_terminal_size_changed(terminal.get_cols(), terminal.get_rows())
	await get_tree().create_timer(.3).timeout
	pty.write("cd ~/Desktop/asideness")
	push_note()
	create_file(path + "/cfg_reload.sh", "#!/bin/bash\n\nexec 3<>/dev/tcp/127.0.0.1/9000\necho \"cfg_reload\" >&3\nexec 3>&-", true)

func push_note() :
	var file = FileAccess.open(path + "/note.md", FileAccess.WRITE)
	file.store_string(lvl.note + "\n")
	file.close()

#func _on_command_received(command: String):
	#print("-> Получена команда из файловой системы Linux: ", command)
	#match command:
		#"player.jump":
			#print("Действие: Персонаж прыгает!")
			## $Player.jump()
		#"open.door":
			#print("Действие: Дверь открыта!")
		#"exit":
			#is_listening = false
			#get_tree().quit()

#endregion
