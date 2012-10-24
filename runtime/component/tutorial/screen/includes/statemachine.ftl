<script src="/resources/joint/json2.js" type="text/javascript"></script>
<script src="/resources/joint/raphael.js" type="text/javascript"></script>
<script src="/resources/joint/joint.js" type="text/javascript"></script>
<script src="/resources/joint/joint.arrows.js"" type="text/javascript"></script>
<script src="/resources/joint/joint.dia.js" type="text/javascript"></script>
<script src="/resources/joint/joint.dia.serializer.js" type="text/javascript"></script>
<script src="/resources/joint/joint.dia.fsa.js" type="text/javascript"></script>


<div id="myfsa"></div>

<#assign start = xmlNode["@initialstate"] >
<script type="text/javascript">

var start_state_name = '${xmlNode["@initialstate"]}';
var state_machine = {};
var currnt_state = null;

function test_exec(){
    var event_name;
    if (currnt_state){
        if (state_machine[currnt_state].transitions && state_machine[currnt_state].transitions.length > 0){
            if(state_machine[currnt_state].object == "EndState")
            event_name = state_machine[currnt_state].transitions[0].event;
        }
    }
    $.ajax({
        url: 'workflow/wfexec',
        data: {state: currnt_state, 'event': event_name},
        type: 'POST',
        success: function(subject) {
            if (subject && subject.id){
                currnt_state = subject.state;
                state_machine[subject.state].highlight();
                if(state_machine[subject.state].object == "EndState"){
                    $('#btn_exec').attr('disabled', true);
                    $('#btn_exec').text('流程结束');
                }
            }
        }
    })
}

$(document).ready(function(){
    var fsa = Joint.dia.fsa;
    Joint.paper("myfsa", 960, 200);

    var all_state_array = [];
    <#list xmlNode["state"] as stateNode>
        <#assign id = stateNode["@id"]>
        <#assign position = stateNode["position"][0]>
        <#assign label = stateNode["@label"]?if_exists>
        <#if id == start>
            state_machine['${id}'] = fsa.StartState.create({ position: {x: ${position["@x"]}, y: ${position["@y"]}} });
        <#elseif stateNode["@final"]?if_exists == "true">
            state_machine['${id}'] = fsa.EndState.create({ position: {x: ${position["@x"]}, y: ${position["@y"]}} });
        <#else>
            state_machine['${id}'] = fsa.State.create({ position: {x: ${position["@x"]}, y: ${position["@y"]}}, label: "${label}" });
        </#if>

        all_state_array.push(state_machine['${id}']);
        <#assign transitions = stateNode["transition"]?if_exists>
        <#if transitions?has_content>
            state_machine['${id}'].transitions = []
            <#list transitions as transition>
                <#assign event = transition["@event"]?if_exists>
                <#assign label = transition["@label"]?if_exists>
                <#assign target = transition["@target"]>
                state_machine['${id}'].transitions.push({
                event: <#if event?has_content>'${event}'<#else>null</#if>
                    , target: '${target}'
                    , label: '${label}'
                });
            </#list>
        </#if>
    </#list>

    for(var state_id in state_machine){
        var state = state_machine[state_id];
        if (state.transitions){
            for(var i = 0; i < state.transitions.length; i ++){
                var transition = state.transitions[i];
                fsa.arrow.label = transition.label;
                state.joint(state_machine[transition.target], fsa.arrow).register(all_state_array);
            }
        }
    }
    //解决firefox自动保存button状态的问题
    $('#btn_exec').attr('disabled', false);
})


</script>