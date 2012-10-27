requirejs.config({
    urlArgs: 'cacheKey=1.0.10',
    //By default load any module IDs from js/lib
    baseUrl: '/resources',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        json2: 'joint/json2-min',
        raphael: 'joint/raphael-min',
        joint: 'joint/joint',
        'joint.arrows': 'joint/joint.arrows',
        'joint.dia': 'joint/joint.dia',
        'joint.dia.serializer': 'joint/joint.dia.serializer',
        'joint.dia.fsa': 'joint/joint.dia.fsa',
        'statemachine': 'moqui/statemachine'
    },

    shim: {
        'joint': ['raphael', 'json2'],
        'joint.arrows': ['joint'],
        'joint.dia': ['joint.arrows'],
        'joint.dia.serializer': ['joint.dia'],
        'joint.dia.fsa': ['joint.dia.serializer'],
        'statemachine': ['joint.dia.fsa']
    }
});

