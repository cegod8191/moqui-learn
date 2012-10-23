import org.moqui.addons.statemachine.StateMachine
import org.apache.log4j.Logger

def logger = Logger.getLogger("test");

class StateMachineTests {
    def logger = Logger.getLogger("test");

    void testBasicTransition() {
        def subject = [state:"state_a"]
        def event = "event_a"
        def machineMap = [
                "state_a" : [[event:"event_a", target:"state_b"]],
                "state_b" : []
        ]

        StateMachine.transition(event, machineMap, subject)

        assert "state_b" == subject.state
    }

    void testcondedTransition() {
        def subject = [state:"state_a"]
        def event = "event_a"
        def machineMap = [
                "state_a" : [[cond:{false}, event:"event_a", target:"state_b"],
                        [cond:{true}, event:"event_a", target:"state_c"]],
                "state_b" : [],
                "state_c" : []
        ]

        StateMachine.transition(event, machineMap, subject)

        assert "state_c" == subject.state
    }

    void testActionPerformed() {

        def subject = [state:"state_a", actionPerformed:false]
        def event = "event_a"
        def machineMap = [
                "state_a" : [[event:"event_a", target:"state_b", action:{it.actionPerformed = true}]],
                "state_b" : []
        ]

        StateMachine.transition(event, machineMap, subject)

        assert "state_b" == subject.state
        assert subject.actionPerformed
    }

    void testDslBuildsCorrectStructure() {

        Closure cl = { println "cl" }
        Closure cl1 = { println "cl1" }
        Closure cl2 = { println "cl2" }
        Closure cl3 = { println "cl3" }
        def expected_state_machine = [
                (null): [
                        [event: "customerSubmitsRegistrationForVerifificationByCdn", target: "WAITING_FOR_CDN_VERIFICATION", action: cl],
                        [event: "customerSelectsToBeNotifiedWhenNmiReady", target: "WAITING_FOR_NMI_TO_BE_READY"]
                ],
                ("WAITING_FOR_CDN_VERIFICATION"): [
                        [event: "verifiedByCdn", target: "ACTIVE", action: cl1],
                        [event: "retailerApprovesRegistration", target: "ACTIVE", action: cl1],
                        [event: "retailerRejectsRegistration", target: "REJECTED_BY_RETAILER"],
                        [event: "retailerDetectsRegistrationError", target: "CORRECTING_REGISTRATION"],
                        [event: "esbReportedCustomerMovedOut", target: "MOVED_OUT", action: cl2]
                ],
                ("WAITING_FOR_VERIFICATION"): [
                        [event: "retailerApprovesRegistration", target: "ACTIVE", action: cl1],
                        [event: "retailerRejectsRegistration", target: "REJECTED_BY_RETAILER"],
                        [event: "retailerDetectsRegistrationError", target: "CORRECTING_REGISTRATION"],
                        [event: "esbReportedCustomerMovedOut", target: "MOVED_OUT", action: cl2],
                        [event: "customerChangesRetailer", target: "CHANGED_RETAILER", action: cl3]
                ]
        ]

        def actualStateMachine = StateMachine.build {
            state(null) {
                event("customerSubmitsRegistrationForVerifificationByCdn") {
                    target "WAITING_FOR_CDN_VERIFICATION"
                    action(cl)
                }
                event("customerSelectsToBeNotifiedWhenNmiReady", target: "WAITING_FOR_NMI_TO_BE_READY")
            }

            state("WAITING_FOR_CDN_VERIFICATION") {
                event "verifiedByCdn", target: "ACTIVE", action: cl1
                event "retailerApprovesRegistration", target: "ACTIVE", action: cl1
                event "retailerRejectsRegistration", target: "REJECTED_BY_RETAILER"
                event "retailerDetectsRegistrationError", target: "CORRECTING_REGISTRATION"
                event "esbReportedCustomerMovedOut", target: "MOVED_OUT", action: cl2
            }

            state("WAITING_FOR_VERIFICATION") {
                event "retailerApprovesRegistration", target: "ACTIVE", action: cl1
                event "retailerRejectsRegistration", target: "REJECTED_BY_RETAILER"
                event "retailerDetectsRegistrationError", target: "CORRECTING_REGISTRATION"
                event "esbReportedCustomerMovedOut", target: "MOVED_OUT", {
                    action cl2
                }
                event "customerChangesRetailer", {
                    target "CHANGED_RETAILER"
                    action cl3
                }
            }
        }

        assert actualStateMachine == expected_state_machine
    }

    void shouldAllowAnActionOnEntryToAState() {
        def trans = []
        def stateMap = StateMachine.build {
            state(null) {
                event "event1", target: 'A', action: { trans << 1 }
            }
            state('A') {
                onEntry { trans << 2 }
                event "event2", target: 'B', action: { trans << 3 }
            }
            state('B') {
                onEntry { trans << 4 }
                event "event1", target: 'A', action: { trans << 5 }
            }
        }

        def subject = [state: null]

        StateMachine.transition('event1', stateMap, subject)
        StateMachine.transition('event2', stateMap, subject)
        StateMachine.transition('event1', stateMap, subject)

        assert trans == [1, 2, 3, 4, 5, 2]
    }

    void testcondedTransitionWithDsl() {
        def subject = [state:"state_a"]

        def machineMap = StateMachine.build {
            state("state_a") {
                event "event_a", cond: {false}, target: "state_b"
                event "event_a",  {
                    cond {true}
                    target "state_c"
                }
            }
            state "state_b"
            state "state_c"
        }

        StateMachine.transition("event_a", machineMap, subject)

        assert "state_c" == subject.state
    }

    void testFlow1(){
        def trans = []
        def machineMap = [
            "采购下单完成" : [
                    {trans << "s1"}
                    ,[event:"采购申请", cond: {it.amount>=10000}, target:"财务审核", action: {trans << "action1"; it.amount++}]
                    ,[event:"采购申请", cond: {it.amount<10000}, target:"审核完成"]
            ],
            "财务审核" : [
                    {trans << "s2"}
                    ,[event: "未超预算", target: "审核完成"]
                    ,[event: "超过预算", target: "领导审核"]
            ],
            "领导审核": [
                    {trans << "s3"}
                    ,[event: "审核通过", target: "审核完成"]
                    ,[event: "审核不通过", target: "采购下单完成"]
            ],
            "审核完成": [
                    {trans << "s4"}
            ]
        ]

        def subject = [state: "采购下单完成", amount: 10000]
        //采购部操作
        StateMachine.transition("采购申请", machineMap, subject)
        //财务部操作
        StateMachine.transition("超过预算", machineMap, subject)
        //领导操作
        StateMachine.transition("审核通过", machineMap, subject)

        assert "审核完成" == subject.state
    }

}

StateMachineTests test = new StateMachineTests()
test.testBasicTransition()
test.testActionPerformed()
test.testDslBuildsCorrectStructure()
test.testcondedTransition()
test.testcondedTransitionWithDsl()
test.shouldAllowAnActionOnEntryToAState()
test.testFlow1()