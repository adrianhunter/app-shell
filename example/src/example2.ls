{AppShell} = require '../../lib/app-shell'
HUBS = [ 'http://localhost:1337' ]

client = null
server = null

window.init-client = (secret)->
    client := new AppShell hubs: HUBS, debug:true

    mysub = client.sub do
        topic: \sometopic
        secret: secret

    # mysub.on \data , (data, e)->
    #     console.log data




window.init-server = ->
    server = new AppShell hubs: HUBS, debug:true


    window.mypub := server.pub \sometopic

    # setTimeout ->
    #     console.log 'publishing some stuff!'
    #     mypub.send \test
    # , 1000




window.client = client
window.server = server
