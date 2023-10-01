class_name GoblinState
extends CharacterBody2D

@export var max_speed    = 40.0
@export var acceleration = 50.0

@onready var animator    = $AnimatedSprite2D
@onready var vision_cast = $RayCast2D

# Definition of the States
enum State {FoundPlayer, LostPlayer}

# previous and current State. The previous state will be
# used to handle transitions.
var pstate = State.LostPlayer
var state  = State.LostPlayer

# Specify transitions here. The first level is the "from" transitions
# it contains another dictionary for the next transitions. This way
# you can add transistions by just defining a data-structure without
# changing the code in _physics_process
var transitions = {
    State.FoundPlayer: {
        State.LostPlayer: FoundPlayer_LostPlayer
    },
    State.LostPlayer: {
        State.FoundPlayer: LostPlayer_FoundPlayer
    }
}

func _ready():
    animator.play("move")

func _physics_process(delta):
    vision_cast.target_position = get_local_mouse_position()
    
    # Generic way to handle all transitions. You only need to
    # specify the transitions in the "transitions" dictionary
    if pstate != state:
        var found = transitions[pstate]
        if found:
            var trans = transitions[pstate][state]
            if trans:
                trans.call()
        pstate = state
    
    # Non-Generic way to handle transitions. You can add those transitions that
    # cannot be handled through the above generic way. For example because the transition
    # function needs additional arguments.
#    if pstate != state:
#        if pstate == State.FoundPlayer && state == State.LostPlayer:
#            transition_LostPlayer_FoundPlayer()
#        pstate = state
    
    # Call the logic for current state
    match state:
        State.FoundPlayer: FoundPlayer(delta)
        State.LostPlayer:  LostPlayer(delta)

## States
func FoundPlayer(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    var direction  = Vector2.ZERO.direction_to(get_local_mouse_position())
    velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
    move_and_slide()
    if vision_cast.is_colliding():
        state = State.LostPlayer

func LostPlayer(delta):
    animator.scale.x = -sign(velocity.x)
    if animator.scale.x == 0.0: animator.scale.x = 1.0
    
    velocity = velocity.move_toward(velocity.normalized() * max_speed, acceleration * delta)
    var collision = move_and_collide(velocity * delta)
    if collision:
        var bounce_velocity = velocity.bounce(collision.get_normal())
        velocity = bounce_velocity
    if not vision_cast.is_colliding():
        state = State.FoundPlayer


## Transitions
func FoundPlayer_LostPlayer():
    print("G1 Lost Player")
    velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * max_speed

func LostPlayer_FoundPlayer():
    print("G1 Found Player")
    
