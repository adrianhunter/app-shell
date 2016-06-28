
swarm = require \webrtc-swarm
signalhub = require \signalhub
{to-hex, create-account} = require \./hyper-utils
EventEmitter = require('events').EventEmitter
memdb = require \memdb
hsodium = require \hyperlog-sodium
split = require \split2
sodium = require \chloride/browser
hyperlog = require \hyperlog
tou8 = require('buffer-to-uint8array')
level = require('level-browserify')
onend = require('end-of-stream')
through = require('through2')
Worker = require('webworkify')
Log = require \./log-service
log = new Log
hypercore = require('hypercore')
MYHUBS = [ 'http://localhost:1337' ]


peers = {}
_sub-streams = {}
subscriptionIndex = 0
state =
    recordId: null


basic-worker-handle = (ev)->
    log.info 'event from <- worker'
    switch ev.data.type
    case \publication.info
        log.info 'New PUBLICATION INFO!!!!!', ev.data
        state.recordId = ev.data.id
        createSwarm(ev.data.id)

    case \peer.data
        log.info('RECV PEER', ev.data.buffer.length)
        peers[ev.data.peerId].write(Buffer(ev.data.buffer))

    case \subscription.data
        log.info('PLAY DATA', ev.data.buffer.length)
        _sub-streams[ev.data.index].write(Buffer(ev.data.buffer))
        # peers[ev.data.peerId].write(Buffer(ev.data.buffer))
        
worker = Worker(require('./worker.js'))
worker.addEventListener \message , basic-worker-handle


export class Sub extends EventEmitter
    ({topic, hubs, db, skip, limit, secret})->
        log.info 'creating new subscription with: ', arguments

        @key = create-account!
        # fookey = new TextEncoder().encode(topic)
        fookey =  tou8(topic)
        createSwarm topic, hubs
        @topic = topic
        index = subscriptionIndex++

        _sub-streams[index] = through()

        worker.postMessage do
            type: 'subscription.start'
            topic: topic
            skip: skip
            secret: secret
            limit: limit
            index: index

export class Pub extends EventEmitter
    ({topic, hubs, db})->
        log.info 'creating new publication with: ', arguments
    
        @topic = topic
        # @db = db
        @key = create-account!
        newKey = 
            publicKey: to-hex @key.publicKey
            privateKey: to-hex @key.secretKey
        log.info newKey
        createSwarm topic, hubs, (peerId)~>
            log.info 'swarm created, peerId: ', peerId
            @peerId = peerId 
        worker.postMessage type: 'publication.start'
    stop:->
    send:(message) ->  worker.postMessage do
        type: 'publication.message'
        message: message
        peerId: @peerId

createSwarm = (topic, hubs, cb) !->
    hubs = hubs or MYHUBS
    log.info 'creating swarm: ', topic, hubs
    swar = swarm(signalhub('spellcast.' + topic, hubs))
    swar.on 'peer', (peer, peerId) !->
        peers[peerId] = peer
        worker.postMessage do
            type: 'peer.start'
            peerId: peerId

        peer.on 'data', (buf) !->
            log.info 'getting peer data from swarm: ', buf
            worker.postMessage(
                type: 'peer.data'
                peerId: peerId
                buffer: buf
            )
            return
        onend peer, !->
            worker.postMessage(
                type: 'peer.end'
                peerId: peerId
            )

        cb peerId if cb

