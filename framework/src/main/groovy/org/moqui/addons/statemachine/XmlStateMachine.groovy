package org.moqui.addons.statemachine

import org.moqui.impl.actions.XmlAction
import org.moqui.context.ExecutionContext

class XmlStateMachine {
    protected ExecutionContext ec
    protected Map stateMachine
    XmlStateMachine(ExecutionContext ec) {
        this.ec = ec
    }

    public Map buildFromXml(String filePath){
        def fileStream = this.ec.ecfi.resourceFacade.getLocationStream(filePath)

        Node smNode = new XmlParser().parse(fileStream)

        Map smMap = new HashMap()
        def initialstate = smNode."@initialstate"

        for (Node stateNode in smNode."state"){
            def nodeMap = []
            if (stateNode."onentry") nodeMap << {
                XmlAction actions = new XmlAction(ec.ecfi, stateNode."onentry"[0], stateNode."@id" + ".onentry")
                ec.context.push()
                ec.context.put("it", it)
                if (actions) actions.run(ec)
                ec.context.pop()
            }
            for (Node transNode in stateNode."transition"){
                Map transMap = new HashMap()
                if (transNode."@event") transMap.put("event", transNode."@event")
                if (transNode."@target") transMap.put("target", transNode."@target")
                if (transNode."@cond") transMap.put("cond", {
                    ec.context.push()
                    ec.context.put("it", it)
                    ec.resource.evaluateCondition(transNode."@cond", null)
                    ec.context.pop()
                })
                if (transNode."action") transMap.put("action", {
                    XmlAction action = new XmlAction(ec.ecfi, transNode."action"[0], stateNode."@id" + transNode."@event" + ".action")
                    ec.context.push()
                    ec.context.put("it", it)
                    if (action) action.run(ec)
                    ec.context.pop()
                })
                nodeMap << transMap
            }
            smMap.put(stateNode."@id", nodeMap)
        }
        this.stateMachine = smMap
        return smMap
    }

    public Map transition(event, subject) {

        StateMachine.transition(event, this.stateMachine, subject)

    }
}
