extends CharacterBody2D

@export var move_speed := 300.0
@export var jump_force := -500.0
@onready var anim = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# 保存站立和下蹲时的碰撞盒形状
var stand_shape: RectangleShape2D
var crouch_shape: RectangleShape2D
# 下蹲状态标记
var is_crouching: bool = false
# 重力
var gravity := Vector2(0, 1800)


func _ready() -> void:
	# 保存初始站立碰撞盒
	stand_shape = collision_shape.shape as RectangleShape2D
	
	# 创建下蹲碰撞盒：宽度不变，高度减半
	crouch_shape = RectangleShape2D.new()
	crouch_shape.size = Vector2(stand_shape.size.x, stand_shape.size.y * 0.5)


func _physics_process(delta: float) -> void:
	# 重力处理
	if not is_on_floor():
		velocity.y += gravity.y * delta

	# ======================== 基础下蹲逻辑 ========================
	# 按下蹲键瞬间触发
	if is_on_floor() and Input.is_action_just_pressed("crouch"):
		is_crouching = true
		anim.play("crouch")
		# 只切换碰撞盒大小，不做任何位置调整
		collision_shape.shape = crouch_shape

	# 松开下蹲键恢复
	if not Input.is_action_pressed("crouch"):
		if is_crouching:
			is_crouching = false
			# 只恢复碰撞盒大小，不做任何位置调整
			collision_shape.shape = stand_shape

	# ======================== 移动逻辑 ========================
	# 下蹲时禁止左右移动
	if is_crouching:
		velocity.x = 0
	else:
		var input_dir = Input.get_axis("move_left", "move_right")
		velocity.x = input_dir * move_speed

	# ======================== 跳跃逻辑 ========================
	# 下蹲状态下不能跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_force

	# 执行物理移动
	move_and_slide()

	# ======================== 动画逻辑 ========================
	if is_crouching:
		# 强制定格在下蹲最后一帧，避免循环
		anim.frame = anim.sprite_frames.get_frame_count("crouch") - 1
	elif not is_on_floor():
		anim.play("jump")
	elif velocity.x != 0:
		anim.play("walk")
		anim.flip_h = velocity.x < 0
	else:
		anim.play("idle")
