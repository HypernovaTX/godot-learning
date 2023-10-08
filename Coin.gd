extends Area2D

var used = false;

func _ready():
	$AnimatedSprite2D.play("default");

func _on_body_entered(body):
	if (body.name == "Player" && !used):
		Global.coins += 1;
		used = true;
		var tween = get_tree().create_tween();
		tween.chain().tween_property(self, 'position', position - Vector2(0, 32), 0.2);
		tween.parallel().tween_property(self, 'modulate:a', 0, 0.2);
		tween.tween_callback(queue_free);

