extends Node2D

@export var enemy_scenes: Array[PackedScene] = []  # 把四種敵人拖進這裡
@export var spawn_interval: float = 1.2            # 增加生成間隔，減少難度
@export var x_margin: float = 50.0                 # 增加邊距，避免貼邊出生

@onready var _timer: Timer = $Timer

func _ready() -> void:
	randomize()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timer_timeout)
	_timer.start()

func _on_timer_timeout() -> void:
	spawn_enemy()

func get_spawn_position() -> Vector2:
	# 使用硬編碼的 1024x1024 視窗大小
	var left := x_margin  # 50
	var right := 1024 - x_margin  # 974
	var x := randf_range(left, right)
	
	# Y 位置在螢幕上方生成
	var y := randf_range(-150.0, -20.0)
	
	return Vector2(x, y)

func spawn_enemy() -> void:
	if enemy_scenes.is_empty(): return
	var scene: PackedScene = enemy_scenes[randi() % enemy_scenes.size()]
	var e: Area2D = scene.instantiate()

	# 使用新的生成位置算法
	e.position = get_spawn_position()

	# 暫時註解掉信號連接，避免錯誤
	# e.touched_boundary.connect(get_parent()._on_enemy_touched_boundary)
	# e.enemy_destroyed.connect(get_parent()._on_enemy_destroyed)
	# e.hit_player.connect(get_parent()._on_enemy_hit_player)

	add_child(e)
