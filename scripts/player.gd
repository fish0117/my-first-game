extends CharacterBody2D

@export var move_speed := 800.0
@export var bottom_margin := 72.0
@export var screen_margin := 12.0
@export var bullet_scene: PackedScene
@export var fire_cooldown := 0.15

var _cd := 0.0
@onready var _vp := get_viewport()

func _ready():
	visible = false
	set_process(false)
	set_physics_process(false)

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_place_at_bottom()

func _place_at_bottom():
	global_position.x = 512
	global_position.y = 900
	visible = true
	modulate = Color.WHITE

func _physics_process(delta):
	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * move_speed
	velocity.y = 0.0
	
	move_and_slide()

	var player_width := 50.0
	var left := player_width
	var right := 1024 - player_width
	
	global_position.x = clamp(global_position.x, left, right)
	global_position.y = 900

	_cd = max(_cd - delta, 0.0)
	if Input.is_action_pressed("shoot") and _cd == 0.0:
		_shoot()
		_cd = fire_cooldown

func _shoot():
	if bullet_scene == null:
		return
	var b = bullet_scene.instantiate()
	
	var bullet_spawn = get_node_or_null("BulletSpawn")
	if bullet_spawn:
		b.global_position = bullet_spawn.global_position
	else:
		b.global_position = global_position + Vector2(0, -50)
	
	b.z_index = 10
	get_tree().current_scene.add_child(b)
