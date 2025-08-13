extends Area2D
signal touched_boundary            # 碰到邊界時發射給外面（Main）
signal enemy_destroyed(points: int)  # 敵人被擊敗時發射信號
signal hit_player                   # 碰到玩家時發射信號

@export var speed: float = 120.0   # 減慢敵人速度，給玩家更多反應時間
@export var bottom_margin: float = 0.0   # 距離底邊的判定預留（可視需要 >0）
@export var max_health: int = 1    # 敵人血量
@export var points_value: int = 100  # 擊敗獲得分數

var current_health: int

func _ready():
	current_health = max_health
	# 連接碰撞檢測信號，用於檢測玩家
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 檢查是否碰到玩家
	if body.name == "Player" or body.is_in_group("player"):
		hit_player.emit()
		queue_free()  # 碰到玩家後敵人也消失

func take_damage(damage: int):
	current_health -= damage
	
	# 視覺反饋：受傷閃爍
	_flash_damage()
	
	if current_health <= 0:
		# 發送被擊敗信號
		enemy_destroyed.emit(points_value)
		queue_free()

func _flash_damage():
	# 簡單的受傷閃爍效果
	var sprite = get_node("Sprite2D")
	if sprite:
		sprite.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _physics_process(delta: float) -> void:
	position.y += speed * delta

	# 檢查所有邊界，使用硬編碼的 1024x1024 視窗
	var screen_margin := 50.0  # 邊界緩衝區
	
	# 限制左右邊界
	position.x = clamp(position.x, screen_margin, 1024 - screen_margin)
	
	# 檢查是否觸碰到底邊（遊戲結束條件）
	if position.y >= 1024 - bottom_margin:
		emit_signal("touched_boundary")
		set_process(false)  # 停止處理
	
	# 如果敵人跑到太遠的地方，直接刪除（清理）
	if position.y > 1200:  # 超出螢幕很多
		queue_free()
