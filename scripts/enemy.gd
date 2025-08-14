extends Area2D
signal touched_boundary
signal enemy_destroyed(points: int)
signal hit_player

@export var base_speed: float = 120.0
@export var bottom_margin: float = 0.0
@export var max_health: int = 1
@export var points_value: int = 100

var current_health: int
var current_speed: float

func _ready():
	current_health = max_health
	current_speed = base_speed
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		hit_player.emit()
		queue_free()

func take_damage(damage: int):
	current_health -= damage
	_flash_damage()
	if current_health <= 0:
		enemy_destroyed.emit(points_value)
		queue_free()

func _flash_damage():
	var sprite = get_node("Sprite2D")
	if sprite:
		sprite.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func update_speed(time_remaining: float):
	var time_factor = (60.0 - time_remaining) / 60.0
	current_speed = base_speed + (base_speed * 2.0 * time_factor)

func _physics_process(delta: float) -> void:
	position.y += current_speed * delta
	var screen_margin := 50.0
	position.x = clamp(position.x, screen_margin, 1024 - screen_margin)
	
	if position.y >= 1024 - bottom_margin:
		emit_signal("touched_boundary")
		set_process(false)
	
	if position.y > 1200:
		queue_free()
