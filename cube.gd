@tool
extends Node3D

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		_update_sides()


func _ready():
	_update_sides()


func _update_sides():
	for child in get_children():
		child.set_instance_shader_parameter("albedo", color)
