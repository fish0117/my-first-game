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

	# 只檢查「觸碰到底邊」就算遊戲結束（你要四邊都算也可改）
	var vr := get_viewport().get_visible_rect()
	var bottom := vr.position.y + vr.size.y
	if position.y >= bottom - bottom_margin:
		emit_signal("touched_boundary")
		# 可視需要：也可先停掉自己
		set_process(false)
