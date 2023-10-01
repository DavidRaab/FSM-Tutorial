class_name GoblinState2
extends CharacterBody2D

@export var max_speed    = 40.0
@export var acceleration = 50.0

@onready var animator    = $AnimatedSprite2D
@onready var vision_cast = $RayCast2D

# Definition for the Finite-State-Machine. Those variables are passed
# to the FSM.fsm() function. Defined in FSM.gd
var state  = {}
var config = {
    Start  = "LostPlayer",
    States = {
        FoundPlayer = FoundPlayer,
        LostPlayer  = LostPlayer,
    },
    Transitions = {
        FoundPlayer_LostPlayer = FoundPlayer_LostPlayer,
        LostPlayer_FoundPlayer = func(delta): print("G2 Found Player"),
    }
}

func _ready():
    animator.play("move")

func _physics_process(delta):
    vision_cast.target_position = get_local_mouse_position()
    FSM.fsm(state, delta, config)

## States
func FoundPlayer(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    var direction  = Vector2.ZERO.direction_to(get_local_mouse_position())
    velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
    move_and_slide()
    
    return "LostPlayer" if vision_cast.is_colliding() else "FoundPlayer"

func LostPlayer(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    velocity = velocity.move_toward(velocity.normalized() * max_speed, acceleration * delta)
    var collision = move_and_collide(velocity * delta)
    if collision:
        var bounce_velocity = velocity.bounce(collision.get_normal())
        velocity = bounce_velocity
    
    return "LostPlayer" if vision_cast.is_colliding() else "FoundPlayer"


## Transitions
func FoundPlayer_LostPlayer(delta):
    print("G2 Lost Player")
    velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * max_speed

    
