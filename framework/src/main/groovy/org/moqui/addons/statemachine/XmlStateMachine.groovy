package org.moqui.addons.statemachine

import org.moqui.impl.actions.XmlAction
import org.moqui.context.ExecutionContext

class XmlStateMachine extends StateMachine{
    protected ExecutionContext ec
    protected String initial_state
    protected String location
    XmlStateMachine(ExecutionContext ec) {
        this.ec = ec
        this.location = ec.context.get("location")
        if (this.location){
            this.build()
        }
    }

    public String getLocatoin(){
        return this.location;
    }

    public Map build(){
        this.build(this.location)
    }

    public Map build(String filePath){
        def fileStream = ec.ecfi.resourceFacade.getLocationStream(filePath)

        Node smNode = new XmlParser().parse(fileStream)

        Map smMap = new HashMap()
        this.initial_state = smNode."@initialstate"

        for (Node stateNode in smNode."state"){
            def nodeMap = []
            if (stateNode."onentry") nodeMap << {
                XmlAction actions = new XmlAction(ec.ecfi, stateNode."onentry"[0], stateNode."@id" + ".onentry")
                ec.context.push()
                ec.context.put("subject", it)
                if (actions) actions.run(ec)
                ec.context.pop()
            }

            for (Node transNode in stateNode."transition"){
                Map transMap = new HashMap()
                if (transNode."@event") transMap.put("event", transNode."@event")
                if (transNode."@target") transMap.put("target", transNode."@target")
                if (transNode."condition" && transNode."condition"[0].children()) {
                    //闭包中不能使用外部引用的对象变量,先在外面赋值
                    Node condNode = transNode."condition"[0].children()[0]
                    String location = stateNode."@id" + "." + transNode."@event" + "." + transNode."@target" + ".condition"
                    transMap.put("cond", {
                        XmlAction condition = new XmlAction(ec.ecfi, condNode, location)

                        ec.context.push()
                        ec.context.put("subject", it)
                        def result = condition ? condition.checkCondition(ec) : true
                        //def result = ec.resource.evaluateCondition(cond, location)
                        ec.context.pop()
                        return result
                    })
                }
                if (transNode."action"){
                    //闭包中不能使用外部引用的对象变量,先在外面赋值
                    Node actionNode = transNode."action"[0]
                    String location = stateNode."@id" + transNode."@event" + "." + transNode."@target" + ".action"
                    transMap.put("action", {
                        XmlAction action = new XmlAction(ec.ecfi, actionNode, location)
                        ec.context.push()
                        ec.context.put("subject", it)
                        if (action) action.run(ec)
                        ec.context.pop()
                    })
                }
                nodeMap << transMap
            }
            smMap.put(stateNode."@id", nodeMap)
        }
        this.stateMachineMap = smMap
        return smMap
    }

    public static Node buildDocument(ExecutionContext ec, String filePath){
        def fileStream = ec.ecfi.resourceFacade.getLocationStream(filePath)
        Node node = new XmlParser().parse(fileStream)
        return node
    }

    public Map start(Map subject){
        subject.state = this.initial_state
        return StateMachine.transition(null, this.stateMachineMap, subject)
    }

    public Map transition(event, subject) {
        return StateMachine.transition(event, this.stateMachineMap, subject)
    }
}
