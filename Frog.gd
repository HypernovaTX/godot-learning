extends CharacterBody2D;

# Config
const SPEED = 100.0;
const JUMP_VELOCITY = -400.0;
const TIMER = 30;
const TERMINAL_FALL = 300;

# States
@onready var sprite = $Sprite as AnimatedSprite2D;
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity');
var player;
var chase = false;
var timer = 1;
var jumped = 0;
var dying = false;
var player_interacted = false;

# Events
func _ready():
	sprite.play('Idle');

func _physics_process(delta: float):
	if (dying || is_player_dying()):
		return;
	physics(delta);
	# Detection
	move_towards_player();

func _process(_delta: float):
	animation();

func _on_player_detection_body_entered(body: Node2D):
	if (is_player(body)):
		chase = true;

func _on_player_detection_body_exited(body: Node2D):
	if (is_player(body)):
		chase = false;
		timer = TIMER;


func _on_player_stomp_body_entered(body: Node2D):
	if (is_player(body) && !body.is_on_floor() && !body.dying && !dying && !player_interacted):
		Global.coins += 1;
		player_interacted = true;
		dying = true;
		body.velocity.y = -300;
		remove_child(get_node("./PlayerHurt"));
		velocity = Vector2(0, 0);
		# For async:
		# await sprite.animation_finished;

func _on_player_stomp_body_exited(body):
	if (is_player(body) && !dying && !body.dying && player_interacted):
		player_interacted = false;

func _on_player_hurt_body_entered(body: Node2D):
	if (is_player(body) && !dying && !body.dying):
		player_interacted = true;
		body.hurt_player();

func _on_animated_sprite_2d_animation_finished():
	if (sprite.animation == 'Death'):
		self.queue_free();

# Main
func physics(delta: float):
	if (!is_on_floor() && velocity.y < TERMINAL_FALL):
		velocity.y += gravity * delta;
	move_and_slide();

func animation():
	if (dying):
		sprite.play('Death');
		return;
	var direction = get_direction();
	if (direction):
		sprite.flip_h = direction > 0;
	if (is_on_floor()):
		sprite.play('Idle');
	else:
		sprite.play('Jump');
		sprite.set_frame(1 if (velocity.y < 0) else 2);

func move_towards_player():
	var direction = get_direction();
	if (chase):
		if (timer > 0):
			timer -= 1;
		elif (!jumped && is_on_floor()):
			jumped = 1;
			velocity.x = direction * SPEED if (chase) else 0;		
			velocity.y = JUMP_VELOCITY;
		if (!is_on_floor() && velocity.y >= 0 && jumped == 1):
			jumped = 2;
		if (jumped == 2 && is_on_floor()):
			velocity.x = 0;
			jumped = 0;
			timer = TIMER;

# Util
func get_player():
	return get_node_or_null('../../Player/Player');

func get_direction():
	player = get_player();
	if (player == null):
		push_error('ERR(Frog): Player instance not found!');
		return 0;
	return (player.position - self.position).normalized().x;

func is_player_dying():
	player = get_player();
	if (player == null):
		push_error('ERR(Frog): Player instance not found!');
		return true;
	return player.dying;

func is_player(body: Node2D):
	return body.name == 'Player';





