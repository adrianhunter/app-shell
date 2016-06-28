
window = window? or self? or @

transform-object = -> 
    if typeof it is 'object' and not (it instanceof Array) 
        JSON.stringify it, null, 2
    else it

transform-strings = (args, {backgrounds, colors})-> 
    args.map (arg,i)->
        used-strings = 0
        if typeof arg is 'string'
            arg = '%c '+arg
            args.splice(i, 0, "background: ##{backgrounds[used-strings]}; color: ##{colors[used-strings]}")
            used-strings++
        arg    

transform-args = (args, settings)-> 
    args = transform-strings args, settings
    args.map (arg, i)~> transform-object arg

class LogService
    ({backgrounds = ['#fff'], colors = ['#000']} = {})->
        @settings.backgrounds: backgrounds
        @settings.colors: colors

    settings: {
        backgrounds: [] 
        colors: [] 
    }

    


        
    info:(...args)!->
        console.info.apply null, transform-args args, @settings



module.exports = LogService
   

    