test = require('tape')
{AppShell} = require '../lib/app-shell'

TEST-MESSAGE = 'hello hyper galaxy!'
TEST-TOPIC = 'jklhaskdjhlakjsd'

HUBS = [ 'http://localhost:1337' ]


server = null
client = null

test 'create a instance and check basic stuff', (t) !->
    t.plan 2

    server := new AppShell hubs: HUBS, opts:
        debug:true
    client := new AppShell hubs: HUBS, opts:
        debug:true

    t.equal typeof server.pub, 'function'
    t.equal typeof server.sub, 'function'



# test 'check basic functions', (t) !->
#     t.plan 3

#     server = new AppShell hubs: HUBS, opts:
#         debug:true

#     t.equal typeof server.pub, 'function'
#     t.equal typeof server.sub, 'function'
    
    
#     mypub = server.pub \sometopic


#     t.equal typeof mypub.send, 'function'

publishId = null

test 'publish some strings', (t) !->
    t.plan 1

    mypub = server.pub TEST-TOPIC

    mypub.send TEST-MESSAGE

    mysub = client.sub TEST-TOPIC
    mysub.on \data , (data, e)->
        console.log data
        t.equal typeof data, 'object'
        



