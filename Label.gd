extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = get_node("../../Player/Player");
	if (!player):
		return;
	var display = "health: %s"
	text = display % str(player.health);
