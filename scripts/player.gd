extends CharacterBody2D

@export var move_speed := 800.0        # 增加移動速度
@export var bottom_margin := 72.0
@export var screen_margin := 12.0
@export var bullet_scene: PackedScene
@export var fire_cooldown := 0.15      # 增加射擊間隔，讓遊戲更平衡

var _cd := 0.0
@onready var _vp := get_viewport()

func _ready():
	# 建議把 CharacterBody2D → Motion Mode 設成 Floating（在 Inspector）
	print("Player _ready() called")
	print("Initial position: ", global_position)
	print("Initial scale: ", scale)
	_place_at_bottom()
	print("After _place_at_bottom: ", global_position)

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_place_at_bottom()

func _place_at_bottom():
	# 先嘗試明顯的位置來測試
	global_position.x = 512  # 1024 / 2 = 512 (螢幕中央)
	global_position.y = 900  # 更靠近底部，但不會太下面
	
	# 調試信息
	print("Player position set to: ", global_position)
	print("Viewport size: ", _vp.get_visible_rect().size)
	print("Viewport position: ", _vp.get_visible_rect().position)
	
	# 確保 Player 可見
	visible = true
	modulate = Color.WHITE  # 確保沒有透明度問題

func _physics_process(delta):
	# 只允許左右移動 - 使用原本的輸入映射
	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * move_speed
	velocity.y = 0.0  # 確保不會垂直移動
	
	move_and_slide()

	# 限制玩家在螢幕範圍內 - 使用簡單的硬編碼值
	var left  := screen_margin  # 12
	var right := 1024 - screen_margin  # 1012
	
	# 保持在底部，只限制左右邊界
	global_position.x = clamp(global_position.x, left, right)
	global_position.y = 950  # 固定在底部

	# 射擊邏輯
	_cd = max(_cd - delta, 0.0)
	if Input.is_action_pressed("shoot") and _cd == 0.0:
		_shoot(); _cd = fire_cooldown

func _shoot():
	if bullet_scene == null:
		push_warning("尚未指定 bullet_scene"); return
	var b = bullet_scene.instantiate()
	
	# 安全地獲取子彈發射位置
	var bullet_spawn = get_node_or_null("BulletSpawn")
	if bullet_spawn:
		b.global_position = bullet_spawn.global_position
	else:
		# 如果找不到 BulletSpawn，使用玩家位置稍微向上偏移
		b.global_position = global_position + Vector2(0, -50)
		print("Warning: BulletSpawn node not found, using player position")
	
	b.z_index = 10
	get_tree().current_scene.add_child(b)
