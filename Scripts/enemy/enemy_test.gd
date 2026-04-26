extends CharacterBody2D

var gravity := Vector2(0, 1800)
var move_speed := 225.0
var chase := false

# 攻击参数
@export var attack_range = 70.0
@export var attack_cd = 1.3
var can_attack = true
var is_attacking = false

# 跳跃参数（极简版）
@export var jump_force = -600.0  # 跳得更高一点
@export var jump_cooldown = 0.5
var jump_timer = 0.0
var was_on_floor = false

# 节点引用
@onready var anim = $AnimatedSprite2D
@onready var detection_area = $Area2D
var player: Node2D = null


func _ready():
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)


func _physics_process(delta: float) -> void:
	# 跳跃冷却
	if jump_timer > 0:
		jump_timer -= delta

	# 重力
	if not is_on_floor():
		velocity.y += gravity.y * delta

	# 记录上一帧是否在地面
	was_on_floor = is_on_floor()

	# 待机
	if not chase:
		velocity.x = 0
		if not is_attacking:
			anim.play("Idle")
		move_and_slide()
		return

	# 找玩家
	if not player:
		player = get_tree().get_first_node_in_group("player")
		move_and_slide()
		return

	# 方向
	var dir = sign(player.global_position.x - global_position.x)
	var dis = global_position.distance_to(player.global_position)
	anim.flip_h = dir < 0

	# 攻击
	if dis <= attack_range and can_attack and not is_attacking:
		_do_attack()
		move_and_slide()
		return

	# 追击
	if not is_attacking:
		velocity.x = dir * move_speed
		anim.play("Run")

		# ============= 核心：撞墙就跳 =============
		# 条件：在地面 + 冷却结束 + 前方有地形（不是玩家）
		if is_on_floor() and jump_timer <= 0 and _is_wall_in_front(dir):
			velocity.y = jump_force
			jump_timer = jump_cooldown
	else:
		velocity.x = 0

	move_and_slide()


# ============= 极简墙检测（只检测地形，忽略玩家） =============
func _is_wall_in_front(dir: int) -> bool:
	if dir == 0:
		return false
	
	var space = get_world_2d().direct_space_state
	
	# 射线从角色中心偏下位置发出，向前检测
	var start = global_position + Vector2(dir * 8, -5)
	var end = start + Vector2(dir * 25, 0)
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [self, player] # 排除自己和玩家
	# 只检测第1层（确保是TileMap地形）
	query.collision_mask = 1 
	
	var hit = space.intersect_ray(query)
	
	# 前方有东西（地形）就返回true
	return hit != {}


# 攻击动作
func _do_attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0
	anim.play("Attack1")

	await anim.animation_finished
	is_attacking = false
	anim.play("Idle")

	await get_tree().create_timer(attack_cd).timeout
	can_attack = true


# 玩家检测
func _on_player_detected(body: Node2D) -> void:
	if body.name == "Player":
		chase = true
		player = body

func _on_player_lost(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
		player = null
		velocity.x = 0
