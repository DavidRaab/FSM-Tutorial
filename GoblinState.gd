class_name GoblinState
extends CharacterBody2D

@export var max_speed    = 40.0
@export var acceleration = 50.0

@onready var animator    = $AnimatedSprite2D
@onready var vision_cast = $RayCast2D

enum State {FoundPlayer, LostPlayer}
var pstate = State.LostPlayer # Previous State
var state  = State.LostPlayer # Current State

func _ready():
    animator.play("move")

func _physics_process(delta):
    vision_cast.target_position = get_local_mouse_position()
    
    # if State changed, call transition function
    if pstate != state:
        if pstate == State.FoundPlayer && state == State.LostPlayer:
            transition_chase_to_wander()
        pstate = state
    
    # Call the logic for current state
    if   state == State.FoundPlayer: chase_state(delta)
    elif state == State.LostPlayer: wander_state(delta)


func chase_state(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    var direction  = Vector2.ZERO.direction_to(get_local_mouse_position())
    velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
    move_and_slide()
    if vision_cast.is_colliding():
        state = State.LostPlayer

func wander_state(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    velocity = velocity.move_toward(velocity.normalized() * max_speed, acceleration * delta)
    var collision = move_and_collide(velocity * delta)
    if collision:
        var bounce_velocity = velocity.bounce(collision.get_normal())
        velocity = bounce_velocity
    if not vision_cast.is_colliding():
        state = State.FoundPlayer

func transition_chase_to_wander():
    velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * max_speed
