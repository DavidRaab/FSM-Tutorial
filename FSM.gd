class_name FSM
extends Object

# Example of a config
#var vonfig = {
#    Start  = "Idle",
#    States = {
#        Idle = func():
#            print("Idle")
#            return "Move",
#        Move = func():
#            print("Move")
#            return "Attack",
#        Attack = func():
#            print("Attack")
#            return "Idle",
#    },
#    Transitions = {
#        Move_Attack = func(): print("Near enough to Attack"),
#        Attack_Idle = func(): print("Attacked, now Idle"),
#    },
#}

static func fsm(state, delta, config):
    var start  = config["Start"]
    var states = config["States"].keys()
    var trans  = config["Transitions"]
    
    # If state is empty, that happens on the first call. Then the
    # needed keys are added
    if state.is_empty():
        state["pstate"] = start
        state["state"]  = start
    
    # Run a Transition if state changed and a transition was defined
    if state["pstate"] != state["state"]:
        var fn = trans.get(state["pstate"] + "_" + state["state"])
        if fn:
            fn.call(delta)
    
    # Run the current "state" function
    var run_state = state["state"]
    if run_state in states:
        state["pstate"] = state["state"]
        state["state"]  = config["States"][run_state].call(delta)
    else:
        print("State %s not configured" % run_state)
