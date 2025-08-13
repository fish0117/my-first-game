extends Area2D

@export var speed: float = 1400.0      # 子彈速度
@export var lifetime: float = 3.0      # 最長存活秒數（保險）
@export var margin: float = 32.0       # 超出螢幕多少就刪
@export var damage: int = 1            # 子彈傷害值

var _t := 0.0

func _ready():
	# 連接碰撞檢測信號
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	# 檢查是否擊中敵人
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()  # 子彈銷毀

func _physics_process(delta: float) -> void:
	position.y -= speed * delta
	_t += delta
	if _t >= lifetime:
		queue_free()

	var vp := get_viewport().get_visible_rect()
	if position.y < vp.position.y - margin \
	or position.y > vp.position.y + vp.size.y + margin \
	or position.x < vp.position.x - margin \
	or position.x > vp.position.x + vp.size.x + margin:
		queue_free()
