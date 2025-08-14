extends Area2D

@export var speed: float = 1400.0
@export var lifetime: float = 3.0
@export var margin: float = 32.0
@export var damage: int = 1

var _t := 0.0

func _ready():
	scale = Vector2(0.1, 0.1)
	add_to_group("bullets")
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()

func _physics_process(delta: float) -> void:
	position.y -= speed * delta
	_t += delta
	if _t >= lifetime:
		queue_free()

	var vp := get_viewport().get_visible_rect()
	if position.y < vp.position.y - margin \
	or position.y > vp.position.y + vp.size.y + margin \
	or position.x < vp.position.x - margin \
	or position.x > vp.position.x + vp.size.x + margin:
		queue_free()
