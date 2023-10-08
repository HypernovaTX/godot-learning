extends Node2D

@onready var frogInstance = preload("res://Frog.tscn");
var pressed = false;

func _process(_delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !pressed):
		pressed = true;
		var obj = frogInstance.instantiate();
		obj.position = get_global_mouse_position();
		get_node('Mobs').add_child(obj);
	if (!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && pressed):
		pressed = false;
