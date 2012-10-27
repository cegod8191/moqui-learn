package org.moqui.addons.statemachine

class StateMachine {
    protected final static org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(StateMachine.class)
    protected Map stateMachineMap = [:]
    protected def currentState, currentEvent

    static Map transition(event, Map state_machine, subject) {
        if (!state_machine.containsKey(subject.state)){
            throw new IllegalArgumentException("\"" + subject.state + "\" state not found!")
        }
        def event_has_exists = false
        def transition = state_machine[subject.state].find {
            if (it instanceof Map && it.event == event){
                event_has_exists = true
                !it.cond || it.cond(subject)
            }
        }

        if (!event_has_exists){
            throw new IllegalArgumentException("\"" + event + "\" event not found!")
        }
        if (transition) {
            if (transition.action) {
                transition.action(subject)
            }
            //state change
            subject.lastState = subject.state
            subject.state = transition.target
            def newStateEntry = state_machine[subject.state]
            if (newStateEntry && newStateEntry.first() instanceof Closure) {
                newStateEntry.first().call(subject)
            }
        } else {
            logger.warn("For type=${subject.class} id=${subject.id} state='${subject.state}' the event='$event' does not apply")
        }
        return transition
    }

    static Map build(Closure closure) {
        def stateMachine = new StateMachine()

        closure.delegate = stateMachine
        closure.call()

        stateMachine.stateMachineMap
    }

    void state(def stateKey, Closure closure = null) {
        if (!stateMachineMap.containsKey(stateKey)) {
            stateMachineMap[stateKey] = []
        }
        currentState = stateKey
        if (closure) {
            closure.delegate = this
            closure.call()
        }
    }

    void event(Map options = [:], Object... args) {
        def eventName = args[0]
        Closure closure = null
        if (args[-1] instanceof Closure) {
            closure = args[-1]
        }
        currentEvent = [event: eventName, target: options.target ?: currentState]
        if (options.action) {
            currentEvent.action = options.action
        }
        if (options.cond) {
            currentEvent.cond = options.cond
        }

        if (closure) {
            closure.delegate = this
            closure.call()
        }

        stateMachineMap[currentState] << currentEvent
    }

    void target(def stateKey) {
        currentEvent['target'] = stateKey
    }


    void action(Closure actionClosure) {
        currentEvent['action'] = actionClosure
    }

    void cond(Closure actionClosure) {
        currentEvent['cond'] = actionClosure
    }

    void onEntry(Closure entryAction) {
        List newStateEntry = stateMachineMap[currentState]
        if (newStateEntry && newStateEntry.first() instanceof Closure) {
            newStateEntry[0] = entryAction
        } else {
            newStateEntry.add(0, entryAction)
        }
    }
}