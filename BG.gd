extends ParallaxBackground

var SCROLL_SPEED = 100.0;

func _process(delta: float):
	scroll_offset.x -= SCROLL_SPEED * delta;
