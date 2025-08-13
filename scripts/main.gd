# Main.gd
extends Node2D

# 遊戲狀態枚舉
enum GameState {
	START_SCREEN,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.START_SCREEN

@onready var spawner: Node = _get_spawner_node()
@onready var game_over_label: Label = get_node_or_null("UI/GameOverLabel")
@onready var score_label: Label = get_node_or_null("UI/ScoreLabel")
@onready var start_screen: Control = get_node_or_null("UI/StartScreen")
@onready var player: CharacterBody2D = get_node_or_null("Player")

var is_game_over := false
var current_score := 0

func _get_spawner_node() -> Node:
	var node = get_node_or_null("EnemySpawner")
	if node == null:
		node = get_node_or_null("Enemy-spawner")
	return node

# 遊戲狀態管理
func set_game_state(new_state: GameState):
	current_state = new_state
	
	match current_state:
		GameState.START_SCREEN:
			show_start_screen()
		GameState.PLAYING:
			start_game()
		GameState.GAME_OVER:
			show_game_over()

func show_start_screen():
	# 顯示開始畫面
	if start_screen:
		start_screen.visible = true
		print("開始畫面已顯示")
	else:
		print("錯誤：找不到 start_screen 節點")
	
	# 隱藏遊戲元素
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
		print("玩家已隱藏")
	else:
		print("錯誤：找不到 player 節點")
	
	# 停止敵人生成器
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
		print("敵人生成器已停止")
	else:
		print("錯誤：找不到 spawner 節點")
	
	print("顯示開始畫面")

func start_game():
	# 隱藏開始畫面
	if start_screen:
		start_screen.visible = false
		print("開始畫面已隱藏")
	else:
		print("錯誤：找不到 start_screen 節點")
	
	# 顯示並啟動遊戲元素
	if player:
		player.visible = true
		player.set_process(true)
		player.set_physics_process(true)
		# 重新設置玩家位置
		player._place_at_bottom()
		print("玩家已顯示並啟動")
	else:
		print("錯誤：找不到 player 節點")
	
	# 啟動敵人生成器
	if spawner:
		if spawner.has_method("start_spawning"):
			spawner.start_spawning()
		else:
			spawner.set_process(true)
		print("敵人生成器已啟動")
	else:
		print("錯誤：找不到 spawner 節點")
	
	print("開始遊戲")

func show_game_over():
	# 這裡之後會添加 Game Over 畫面
	print("遊戲結束")

func _on_start_button_pressed():
	print("開始按鈕被按下")
	set_game_state(GameState.PLAYING)

# 敵人生成器信號處理
func _on_enemy_spawned(enemy):
	# 連接敵人的信號
	if enemy.has_signal("enemy_destroyed"):
		enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	if enemy.has_signal("hit_player"):
		enemy.hit_player.connect(_on_enemy_hit_player)
	if enemy.has_signal("touched_boundary"):
		enemy.touched_boundary.connect(_on_enemy_touched_boundary)

func _ready() -> void:
	# 初始化遊戲狀態
	set_game_state(GameState.START_SCREEN)
	
	if game_over_label:
		game_over_label.visible = false
	
	# 初始化分數顯示
	update_score_display()
	
	# 安全連接敵人生成器信號
	if spawner:
		spawner.enemy_spawned.connect(_on_enemy_spawned)
		print("敵人生成器連接成功")
	else:
		print("警告：找不到敵人生成器節點，可能已重命名")
	
	# 連接開始按鈕信號
	if start_screen:
		var start_button = start_screen.get_node_or_null("StartButton")
		if start_button:
			start_button.pressed.connect(_on_start_button_pressed)
			print("開始按鈕連接成功")
		else:
			print("錯誤：找不到 StartButton 節點")
	else:
		print("錯誤：找不到 StartScreen 節點")
	
	# 調試：打印所有找到的節點
	print("找到的節點:")
	print("- spawner: ", spawner)
	print("- start_screen: ", start_screen)
	print("- player: ", player)
	
	# 初始化分數顯示
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(current_score)

func add_score(points: int):
	current_score += points
	update_score_display()

func _on_enemy_destroyed(points: int):
	add_score(points)

func _on_enemy_hit_player():
	# 敵人碰到玩家，遊戲結束
	_trigger_game_over("Game Over - Enemy Hit!\nFinal Score: " + str(current_score) + "\nPress R to restart")

func _trigger_game_over(message: String):
	if is_game_over: 
		return
	is_game_over = true

	# 停止生成器
	if spawner.has_node("Timer"):
		spawner.get_node("Timer").stop()

	# 停止場上所有敵人
	for c in spawner.get_children():
		if c != spawner.get_node("Timer"):  # 不要停止Timer節點
			c.set_process(false)

	# 顯示遊戲結束信息
	if game_over_label:
		game_over_label.text = message
		game_over_label.visible = true

	get_tree().paused = true

# 被 EnemySpawner 代為連接：e.touched_boundary.connect(get_parent()._on_enemy_touched_boundary)
func _on_enemy_touched_boundary() -> void:
	# 敵人觸碰底部邊界，遊戲結束
	_trigger_game_over("Game Over - Enemy Reached Bottom!\nFinal Score: " + str(current_score) + "\nPress R to restart")

func _unhandled_input(event: InputEvent) -> void:
	# 遊戲結束後按 R 重新開始
	if is_game_over and event.is_action_pressed("ui_accept") or (event is InputEventKey and event.physical_keycode == KEY_R):
		get_tree().paused = false
		get_tree().reload_current_scene()
