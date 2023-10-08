extends CharacterBody2D

# Config
const SPEED = 200.0;
const ACCEL = 1200.0;
const DECEL = 600.0;
const JUMP_ACCEL = 900.0;
const JUMP_DECEL = 300.0;
const JUMP_VELOCITY = -600.0;
const JUMP_DECAY = 300.0;
const TERMINAL_FALL = 300;
const whiten_duration = 0.15;
enum { NOT_HURT, HURT_FLASH, HURT_RED, HURT_RECOVER };

# Deps
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D;
@onready var blink: Node = $BlinkEffect;
@onready var camera2d: Camera2D = $Camera2D;
@onready var DeathTimer = $DeathTimer as Timer;
@onready var HurtShader: Shader = preload('res://shaders/Hurt.gdshader');
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity');

# States
var health = 3;
var hurt = NOT_HURT;
var dying = false;
var death_step = 0;

# Events
func _ready():
	sprite.play("Idle");
	sprite.material = ShaderMaterial.new();
	sprite.material.shader = HurtShader;

func _physics_process(delta: float):
	if (dying):
		death_physics(delta);
	else:
		y_physics(delta);
		x_physics(delta);
		move_and_slide();

func _process(_delta: float):
	animation();
	shader();
	handle_death();
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().reload_current_scene();

# Main
func death_physics(delta: float):
	velocity.x = 0;
	position.y += velocity.y * delta;
	if (death_step > 0):
		apply_gravity(delta);
	if (death_step == 1 && velocity.y > 0):
		death_step = 2;
		DeathTimer.wait_time = 3;
		DeathTimer.start();
	
func apply_gravity(delta: float):
	if (velocity.y < TERMINAL_FALL):
		velocity.y += gravity * delta;

func y_physics(delta: float):
	# Gravity
	if (!is_on_floor()):
		apply_gravity(delta);
	# Jump
	if (Input.is_action_just_pressed("ui_accept") && is_on_floor()):
		velocity.y = JUMP_VELOCITY;
	if (Input.is_action_just_released("ui_accept") && !is_on_floor() && velocity.y < -JUMP_DECAY):
		velocity.y += JUMP_DECAY;

func x_physics(delta: float):
	var direction = Input.get_axis("ui_left", "ui_right");
	var target_velocity = direction * SPEED;
	var accel = ACCEL if is_on_floor() else JUMP_ACCEL;
	var decel = DECEL if is_on_floor() else JUMP_DECEL;
	# Acceleration
	if (direction):
		velocity.x = move_toward(velocity.x, target_velocity, accel * delta);
	# Deceleration
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta);

func animation():
	var direction = Input.get_axis("ui_left", "ui_right");
	if (direction):
		sprite.flip_h = direction < 0;
	if (dying):
		sprite.play("Death");
		return;
	if (!is_on_floor()):
		if (velocity.y > 0):
			sprite.play("Fall");
		else:
			sprite.play("Jump");
	else:
		if (velocity.x):
			sprite.play("Run");
		else:
			sprite.play("Idle");

func shader():
	var hurting = hurt == HURT_FLASH || hurt == HURT_RED;
	var flash = hurt if hurting else 0;
	sprite.material.set_shader_parameter('flash', flash);

func hurt_player():
	if (hurt != NOT_HURT):
		return;
	health -= 1;
	self.velocity = Vector2(0, 0);
	if (health <= 0):
		return;
	hurt = HURT_FLASH;
	await get_tree().create_timer(0.05).timeout;
	hurt = HURT_RED;
	await get_tree().create_timer(0.05).timeout;
	hurt = HURT_RECOVER;
	blink.start_blinking(self, 3);
	await get_tree().create_timer(3).timeout;
	hurt = NOT_HURT;

func handle_death():
	if (health <= 0 && !dying):
		health = 0;
		dying = true;
		self.velocity = Vector2(0, 0);
		DeathTimer.wait_time = 1;
		DeathTimer.start();
	#if (dying):
	#	var camera_rect = camera2d.get_viewport_rect();
	#	var offset = 32;
	#	var camera_bottom = camera_rect.position.y + camera_rect.size.y;
	#	if (self.position.y > camera_bottom + offset):
	#		print("outside_view")


func _on_death_timer_timeout():
	DeathTimer.stop();
	if (death_step == 0):
		death_step = 1;
		self.velocity.y = -600;
	elif (death_step == 2):
		get_tree().reload_current_scene();
