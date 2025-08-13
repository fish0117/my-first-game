extends Node2D

signal enemy_spawned(enemy)  # 生成敵人時發射的信號

@export var enemy_scenes: Array[PackedScene] = []  # 把四種敵人拖進這裡
@export var spawn_interval: float = 1.2            # 增加生成間隔，減少難度
@export var x_margin: float = 50.0                 # 增加邊距，避免貼邊出生

@onready var _timer: Timer = $Timer

func _ready() -> void:
	randomize()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timer_timeout)
	
	# 不要立即開始，等待遊戲開始
	# _timer.start()
	
	# 初始狀態設為不處理
	set_process(false)

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

	add_child(e)
	
	# 發射敵人生成信號
	enemy_spawned.emit(e)

# 啟動和停止敵人生成器的方法
func start_spawning():
	set_process(true)
	_timer.start()
	print("敵人生成器已啟動")

func stop_spawning():
	set_process(false)
	_timer.stop()
	print("敵人生成器已停止")
