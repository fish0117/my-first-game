# Main.gd
extends Node2D

# 遊戲狀態枚舉
enum GameState {
	START_SCREEN,
	PLAYING,
	GAME_OVER,
	GOOD_MORNING
}

var current_state: GameState = GameState.START_SCREEN

@onready var spawner: Node = _get_spawner_node()
@onready var game_over_label: Label = get_node_or_null("UI/GameOverLabel")
@onready var score_label: Label = get_node_or_null("UI/ScoreBoard/ScoreLabel")
@onready var time_label: Label = get_node_or_null("UI/GameTimer/TimeLabel")
@onready var score_board: Control = get_node_or_null("UI/ScoreBoard")
@onready var game_timer_ui: Control = get_node_or_null("UI/GameTimer")
@onready var start_screen: Control = get_node_or_null("UI/StartScreen")
@onready var game_over_screen: Control = get_node_or_null("UI/GameOverScreen")
@onready var good_morning_screen: Control = get_node_or_null("UI/GoodMorningScreen")
@onready var final_score_label: Label = get_node_or_null("UI/GameOverScreen/FinalScoreLabel")
@onready var good_morning_final_score_label: Label = get_node_or_null("UI/GoodMorningScreen/FinalScoreLabel")
@onready var restart_button: TextureButton = get_node_or_null("UI/GameOverScreen/RestartButton")
@onready var continue_button: TextureButton = get_node_or_null("UI/GoodMorningScreen/ContinueButton")
@onready var player: CharacterBody2D = get_node_or_null("Player")

var current_score := 0
var game_time := 60.0  # 60秒遊戲時間
var game_timer: Timer

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
		GameState.GOOD_MORNING:
			show_good_morning()

func show_start_screen():
	# 顯示開始畫面
	if start_screen:
		start_screen.visible = true
		print("開始畫面已顯示")
	else:
		print("錯誤：找不到 start_screen 節點")
	
	# 隱藏所有其他畫面
	if game_over_screen:
		game_over_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	
	# 隱藏遊戲UI
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
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
	# 隱藏所有其他畫面
	if start_screen:
		start_screen.visible = false
		print("開始畫面已隱藏")
	else:
		print("錯誤：找不到 start_screen 節點")
	
	if game_over_screen:
		game_over_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	
	# 顯示遊戲UI
	if score_board:
		score_board.visible = true
	if game_timer_ui:
		game_timer_ui.visible = true
	
	# 重置遊戲數據
	current_score = 0
	game_time = 60.0
	update_score_display()
	update_time_display()
	
	# 啟動計時器
	game_timer.start()
	
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
	# 隱藏所有其他畫面
	if start_screen:
		start_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
	# 顯示Game Over畫面
	if game_over_screen:
		game_over_screen.visible = true
		print("Game Over 畫面已顯示")
	else:
		print("錯誤：找不到 game_over_screen 節點")
	
	# 顯示最終分數
	if final_score_label:
		final_score_label.text = "最終分數: " + str(current_score)
		print("最終分數已更新: " + str(current_score))
	else:
		print("錯誤：找不到 final_score_label 節點")
	
	# 停止遊戲計時器
	if game_timer:
		game_timer.stop()
	
	# 隱藏並停用玩家
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
		print("玩家已隱藏並停用")
	
	# 停止敵人生成器
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
		print("敵人生成器已停止")
	
	# 清除場景中的所有敵人
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	print("已清除 ", enemies.size(), " 個敵人")
	
	# 清除場景中的所有子彈
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()
	print("已清除 ", bullets.size(), " 個子彈")
	
	print("遊戲結束")

func show_good_morning():
	# 隱藏所有其他畫面
	if start_screen:
		start_screen.visible = false
	if game_over_screen:
		game_over_screen.visible = false
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
	# 顯示Good Morning畫面
	if good_morning_screen:
		good_morning_screen.visible = true
		print("Good Morning 畫面已顯示")
	else:
		print("錯誤：找不到 good_morning_screen 節點")
	
	# 顯示最終分數
	if good_morning_final_score_label:
		good_morning_final_score_label.text = "最終分數: " + str(current_score)
		print("Good Morning 最終分數已更新: " + str(current_score))
	else:
		print("錯誤：找不到 good_morning_final_score_label 節點")
	
	# 停止遊戲計時器
	if game_timer:
		game_timer.stop()
	
	# 隱藏並停用玩家
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
		print("玩家已隱藏並停用")
	
	# 停止敵人生成器
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
		print("敵人生成器已停止")
	
	# 清除場景中的所有敵人
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	print("已清除 ", enemies.size(), " 個敵人")
	
	# 清除場景中的所有子彈
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()
	print("已清除 ", bullets.size(), " 個子彈")
	
	print("Good Morning！時間到了！")

func _on_start_button_pressed():
	print("開始按鈕被按下")
	set_game_state(GameState.PLAYING)

func _on_restart_button_pressed():
	print("重新開始按鈕被按下")
	# 清理場景中的所有敵人
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	# 清理場景中的所有子彈
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()
	
	# 重新開始遊戲
	set_game_state(GameState.PLAYING)

func _on_continue_button_pressed():
	print("繼續按鈕被按下")
	# 清理場景中的所有敵人
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	# 清理場景中的所有子彈
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()
	
	# 重新開始遊戲
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
	# 創建遊戲計時器
	game_timer = Timer.new()
	game_timer.wait_time = 1.0  # 每秒更新一次
	game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(game_timer)
	
	# 初始化遊戲狀態
	set_game_state(GameState.START_SCREEN)
	
	# 清理任何可能存在的敵人（安全措施）
	var existing_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in existing_enemies:
		enemy.queue_free()
	
	if game_over_label:
		game_over_label.visible = false
	
	# 初始化UI顯示
	update_score_display()
	update_time_display()
	
	# 安全連接敵人生成器信號並確保初始停止
	if spawner:
		# 首先確保敵人生成器處於停止狀態
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		
		spawner.enemy_spawned.connect(_on_enemy_spawned)
		print("敵人生成器連接成功並已停止")
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
	
	# 連接重新開始按鈕信號
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
		print("重新開始按鈕連接成功")
	else:
		print("錯誤：找不到 RestartButton 節點")
	
	# 連接繼續按鈕信號
	if continue_button:
		continue_button.pressed.connect(_on_continue_button_pressed)
		print("繼續按鈕連接成功")
	else:
		print("錯誤：找不到 ContinueButton 節點")
	
	# 調試：打印所有找到的節點
	print("找到的節點:")
	print("- spawner: ", spawner)
	print("- start_screen: ", start_screen)
	print("- player: ", player)
	print("- score_label: ", score_label)
	print("- time_label: ", time_label)
	
	# 初始化分數顯示
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(current_score)

func update_time_display():
	if time_label:
		# 使用浮點除法然後轉換為整數，避免整數除法警告
		var minutes = int(game_time / 60.0)
		var seconds = int(game_time) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_game_timer_timeout():
	if current_state != GameState.PLAYING:
		return
		
	game_time -= 1.0
	update_time_display()
	
	if game_time <= 0:
		# 時間到，遊戲結束
		_trigger_time_up()

func _trigger_time_up():
	game_timer.stop()
	set_game_state(GameState.GOOD_MORNING)
	print("時間到！Good Morning!")

func add_score(points: int):
	current_score += points
	update_score_display()

func _on_enemy_destroyed(points: int):
	add_score(points)

func _on_enemy_hit_player():
	# 敵人碰到玩家，遊戲結束
	if current_state == GameState.PLAYING:
		set_game_state(GameState.GAME_OVER)
		print("敵人撞到玩家！遊戲結束")

func _on_enemy_touched_boundary():
	# 敵人觸碰底部邊界，遊戲結束
	if current_state == GameState.PLAYING:
		set_game_state(GameState.GAME_OVER)
		print("敵人到達底部！遊戲結束")

# 這個函數已經不需要了，新的系統使用狀態管理
# func _unhandled_input(event: InputEvent) -> void:
#   # 舊的重新開始邏輯，已改用按鈕
