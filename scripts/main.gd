extends Node2D

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
var game_time := 60.0
var game_timer: Timer

func _get_spawner_node() -> Node:
	var node = get_node_or_null("EnemySpawner")
	if node == null:
		node = get_node_or_null("Enemy-spawner")
	return node

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
	if game_timer:
		game_timer.stop()
	
	if start_screen:
		start_screen.visible = true
	else:
		print("Error: start_screen node not found")
	
	if game_over_screen:
		game_over_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
	else:
		print("Error: player node not found")
	
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
	else:
		print("Error: spawner node not found")
	
	clear_all_game_objects()

func start_game():
	if game_timer:
		game_timer.stop()
	
	clear_all_game_objects()
	await get_tree().process_frame
	
	if start_screen:
		start_screen.visible = false
	else:
		print("Error: start_screen node not found")
	
	if game_over_screen:
		game_over_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	
	if score_board:
		score_board.visible = true
	if game_timer_ui:
		game_timer_ui.visible = true
	
	current_score = 0
	game_time = 60.0
	update_score_display()
	update_time_display()
	
	if player:
		player.visible = true
		player.set_process(true)
		player.set_physics_process(true)
		player._place_at_bottom()
	else:
		print("Error: player node not found")
	
	if spawner:
		if spawner.has_method("start_spawning"):
			spawner.start_spawning()
		else:
			spawner.set_process(true)
	else:
		print("Error: spawner node not found")
	
	if game_timer:
		game_timer.start()

func show_game_over():
	if start_screen:
		start_screen.visible = false
	if good_morning_screen:
		good_morning_screen.visible = false
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
	if game_over_screen:
		game_over_screen.visible = true
	else:
		print("Error: game_over_screen node not found")
	
	if final_score_label:
		final_score_label.text = "Final Score: " + str(current_score)
	else:
		print("Error: final_score_label node not found")
	
	if game_timer:
		game_timer.stop()
	
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
	
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
	
	clear_all_game_objects()

func show_good_morning():
	if start_screen:
		start_screen.visible = false
	if game_over_screen:
		game_over_screen.visible = false
	if score_board:
		score_board.visible = false
	if game_timer_ui:
		game_timer_ui.visible = false
	
	if good_morning_screen:
		good_morning_screen.visible = true
	else:
		print("Error: good_morning_screen node not found")
	
	if good_morning_final_score_label:
		good_morning_final_score_label.text = "Final Score: " + str(current_score)
	else:
		print("Error: good_morning_final_score_label node not found")
	
	if game_timer:
		game_timer.stop()
	
	if player:
		player.visible = false
		player.set_process(false)
		player.set_physics_process(false)
	
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
	
	clear_all_game_objects()

func _on_start_button_pressed():
	set_game_state(GameState.PLAYING)

func _on_restart_button_pressed():
	clear_all_game_objects()
	await get_tree().process_frame
	set_game_state(GameState.PLAYING)

func _on_continue_button_pressed():
	clear_all_game_objects()
	await get_tree().process_frame
	set_game_state(GameState.PLAYING)

func _on_enemy_spawned(enemy):
	if enemy.has_signal("enemy_destroyed"):
		enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	if enemy.has_signal("hit_player"):
		enemy.hit_player.connect(_on_enemy_hit_player)
	if enemy.has_signal("touched_boundary"):
		enemy.touched_boundary.connect(_on_enemy_touched_boundary)

func clear_all_game_objects():
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		else:
			spawner.set_process(false)
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		bullet.queue_free()
	
	if spawner:
		for child in spawner.get_children():
			if child is Area2D and child.has_method("take_damage"):
				child.queue_free()

func update_enemy_speeds():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("update_speed"):
			enemy.update_speed(game_time)

func _ready() -> void:
	game_timer = Timer.new()
	game_timer.wait_time = 1.0
	game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(game_timer)
	
	set_game_state(GameState.START_SCREEN)
	
	var existing_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in existing_enemies:
		enemy.queue_free()
	
	if game_over_label:
		game_over_label.visible = false
	
	update_score_display()
	update_time_display()
	
	if spawner:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()
		spawner.enemy_spawned.connect(_on_enemy_spawned)
	
	if start_screen:
		var start_button = start_screen.get_node_or_null("StartButton")
		if start_button:
			start_button.pressed.connect(_on_start_button_pressed)
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_button_pressed)
	
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(current_score)

func update_time_display():
	if time_label:
		var minutes = int(game_time / 60.0)
		var seconds = int(game_time) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_game_timer_timeout():
	if current_state != GameState.PLAYING:
		return
		
	game_time -= 1.0
	update_time_display()
	update_enemy_speeds()
	
	if game_time <= 0:
		_trigger_time_up()

func _trigger_time_up():
	game_timer.stop()
	set_game_state(GameState.GOOD_MORNING)

func add_score(points: int):
	current_score += points
	update_score_display()

func _on_enemy_destroyed(points: int):
	add_score(points)

func _on_enemy_hit_player():
	if current_state == GameState.PLAYING:
		set_game_state(GameState.GAME_OVER)

func _on_enemy_touched_boundary():
	if current_state == GameState.PLAYING:
		set_game_state(GameState.GAME_OVER)
