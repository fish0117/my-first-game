# Main.gd
extends Node2D

@onready var spawner: Node = _get_spawner_node()
@onready var game_over_label: Label = get_node_or_null("UI/GameOverLabel")
@onready var score_label: Label = get_node_or_null("UI/ScoreLabel")

var is_game_over := false
var current_score := 0

func _get_spawner_node() -> Node:
	var node = get_node_or_null("EnemySpawner")
	if node == null:
		node = get_node_or_null("Enemy-spawner")
	return node

func _ready() -> void:
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

func _on_enemy_touched_boundary() -> void:
	# 敵人觸碰底部邊界，遊戲結束
	_trigger_game_over("Game Over - Enemy Reached Bottom!\nFinal Score: " + str(current_score) + "\nPress R to restart")

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

func _unhandled_input(event: InputEvent) -> void:
	# 遊戲結束後按 R 重新開始
	if is_game_over and event.is_action_pressed("ui_accept") or (event is InputEventKey and event.physical_keycode == KEY_R):
		get_tree().paused = false
		get_tree().reload_current_scene()
