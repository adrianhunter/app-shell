swarm = require \webrtc-swarm
signalhub = require \signalhub
hsodium = require \hyperlog-sodium
split = require \split2
sodium = require \chloride/browser
hyperlog = require \hyperlog
Log = require \./log-service

log = new Log



{create-account, to-hex} = require \./hyper-utils
{Pub, Sub} = require \./moon-classes
hubs = <[ http://localhost:1337 ]>

export class AppShell   
    subs: []
    pubs: []
    ({hubs, public-key, private-key, debug})->
        window.enable-debug = debug
        @log = log
        log.info 'init app shell with: ', arguments
        
        @key = create-account!
        log.info 'created new account: ', @key
        
        # @db = hyperlog memdb!, hsodium sodium, @key
        @hubs = hubs
    sub:({topic, secret})-> sub = new Sub {topic:topic, secret: secret, hubs: @hubs, db: @db}; @subs.push sub; sub
    pub:(topic)-> pub = new Pub {topic:topic, hubs: @hubs, db: @db}; @pubs.push pub; pub
    get-workers: -> workers

    
 