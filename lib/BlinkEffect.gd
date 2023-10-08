extends Node

@onready var duration_timer = $DurationTimer as Timer;
@onready var blink_timer = $BlinkTimer as Timer;
const blink_speed = 0.05;
var blink_object: Node2D = Node2D.new();
var blinking = false;

func _on_duration_timer_timeout():
	blink_timer.stop();
	duration_timer.stop();
	blink_object.visible = true;

func _on_blink_timer_timeout():
	blink_object.visible = !blink_object.visible;

func start_blinking(object: Node2D, duration: int):
	blink_object = object;
	duration_timer.wait_time = duration;
	blink_timer.wait_time = blink_speed;
	duration_timer.start();
	blink_timer.start();


