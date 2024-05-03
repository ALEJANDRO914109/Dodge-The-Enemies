extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var mov = Vector2()
var screen_size # Size of the game window.
var touch = false
var P
var L=10

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed == true:
			touch = true
			P = event.position
		else:
			touch = false
			
			
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	mov = Vector2()
	
	if touch:
		if  abs(global_position.x - P.x) > L:
			if global_position.x > P.x:
				mov.x -=1
				$AnimatedSprite2D.animation = "Walk"
				$AnimatedSprite2D.flip_v = false
				$AnimatedSprite2D.flip_h = mov.x < 0
			else:
				mov.x +=1
				$AnimatedSprite2D.animation = "Walk"
				$AnimatedSprite2D.flip_v = false
				$AnimatedSprite2D.flip_h = mov.x < 0
		if  abs(global_position.y - P.y) > L:
			if global_position.y > P.y:
				mov.y -=1
				$AnimatedSprite2D.animation = "Up"
				
			else:
				mov.y +=1
				$AnimatedSprite2D.animation = "Down"
		if mov.length() > 0:
			mov = mov.normalized()*speed
		position += mov*delta
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"Walk"
		$AnimatedSprite2D.flip_v = false
		
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = &"Down"
		
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = &"Up"
		rotation = PI if velocity.y > 0 else 0

func start(pos):
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred(&"disabled", true)
