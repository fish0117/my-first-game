extends Node2D

signal enemy_spawned(enemy)

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 1.2
@export var x_margin: float = 50.0

@onready var _timer: Timer = $Timer

func _ready() -> void:
	randomize()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timer_timeout)
	_timer.stop()
	set_process(false)

func _on_timer_timeout() -> void:
	spawn_enemy()

func get_spawn_position() -> Vector2:
	var left := x_margin
	var right := 1024 - x_margin
	var x := randf_range(left, right)
	var y := randf_range(-150.0, -20.0)
	return Vector2(x, y)

func spawn_enemy() -> void:
	if enemy_scenes.is_empty(): return
	var scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]
	var e: Area2D = scene.instantiate()
	e.position = get_spawn_position()
	add_child(e)
	enemy_spawned.emit(e)

func start_spawning():
	set_process(true)
	_timer.start()

func stop_spawning():
	set_process(false)
	_timer.stop()
