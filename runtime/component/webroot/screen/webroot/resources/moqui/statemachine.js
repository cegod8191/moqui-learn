// 定义一个类，构造函数；
var StateMachine = function(name, start, url) {
    this.fsa = Joint.dia.fsa;
    this.url = url;
    this.location;
    this.name = name;
    this.start_state_id = start;
    this.end_state_id;
    this.state_machine = {};
    this.all_state_id = [];
    this.currnt_state = null;
};

// 通过prototype对象定义类的其他成员；
StateMachine.prototype = {
    setStartStateId: function(id){
        this.start_state_id = id;
    },
    setEndStateId: function(id){
        this.end_state_id = id;
    },

    setUrl: function(url){
        this.url = url;
    },

    setLocation: function(location){
        this.location = location;
    },

    createPaper: function(width, height){
        Joint.paper("sm-" + this.name, width, height);
        this.fsa.arrow.attrs["stroke"] = '#999';
        this.fsa.arrow.attrs["stroke-width"] = 1;
    },

    getCurrentEventName: function(){
        var event_name;
        if (this.currnt_state){
            if (this.state_machine[this.currnt_state].transitions && this.state_machine[this.currnt_state].transitions.length > 0){
                if(this.state_machine[this.currnt_state].object != "EndState")
                    event_name = this.state_machine[this.currnt_state].transitions[0].event;
            }
        }
        return event_name;
    },

    exec: function(params, callback) {
        var event_name = this.getCurrentEventName();
        var self = this;
        var data = $.extend({state: this.currnt_state, 'event': event_name, location: this.location}, params);
        $.ajax({
            url: this.url,
            data: data,
            type: 'POST',
            success: function(subject) {
                if (subject && subject.id){
                    self.currnt_state = subject.state;
                    self.state_machine[subject.state].highlight();
                    if (callback){
                        callback.call(self, self.state_machine[subject.state]);
                    }
//                    if(self.state_machine[subject.state].object == "EndState"){
//                        $('#btn_exec').attr('disabled', true);
//                        $('#btn_exec').text('流程结束');
//                    }
                }
            }
        })
    },

    createState: function(id, options){
        var new_state = null;
        if (id == this.start_state_id){
            new_state = this.fsa.StartState.create(options);
        }
        else if (id == this.end_state_id){
            new_state = this.fsa.EndState.create(options);
        }
        else{
            new_state = this.fsa.State.create(options);
        }
        this.state_machine[id] = new_state;
        this.all_state_id.push(new_state);
        //new_state.wrapper.click(this.state_click);
        new_state.registerCallback("mouseDown", this.state_click);
    },

    createTransition: function(id, options){
        if (this.state_machine[id].transitions == undefined){
            this.state_machine[id].transitions = [];
        }
        this.state_machine[id].transitions.push(options)
    },

    state_click: function( e ) {
        console.log(this + '||' + e);
    },
    conn_click: function( e ) {
        console.log(this + '||' + e);
    },

    drawJoints: function(){
        for(var state_id in this.state_machine){
            var state = this.state_machine[state_id];
            if (state.inner.length > 0){
                state.inner[0].click(this.state_click);
            }
            if (state.transitions){
                for(var i = 0; i < state.transitions.length; i ++){
                    var transition = state.transitions[i];
                    this.fsa.arrow.label = transition.label;
                    var conn = state.joint(this.state_machine[transition.target], this.fsa.arrow).register(this.all_state_id);
                    conn.registerCallback("connectionMouseDown", this.conn_click);
                    conn.registerCallback("labelTextClick", this.conn_click);
                }
            }
        }
    }
};

// 实现继承的方法；
StateMachine.extend = function(o, p) {
    if ( !p ) { p = o; o = this; }
    for ( var i in p ) o[ i ] = p[  i ];
    return o;
};

// 对StateMachine进行扩展；
StateMachine.extend({
});
