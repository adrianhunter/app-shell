hypercore = require('hypercore')
level = require('level-browserify')
core = hypercore(level('hypercore'))
Queue = require('ordered-queue')
hubs = [ 'http://localhost:1337' ]
swarm = require \webrtc-swarm

window = self

Log = require \./log-service
log = new Log

tobuf = (blob, cb) !->
    r = new FileReader
    r.addEventListener 'loadend', !->
        cb Buffer(new Uint8Array(r.result))
    r.readAsArrayBuffer blob

module.exports = (self) ->
    mode = null
    feed = undefined
    writeQueue = undefined
    writeSeq = 0
    swarms = {}
    self.addEventListener 'message', (ev) !->
        log.info 'event -> into worker', ev.data

        switch ev.data.type
        case \publication.start
            log \publication-start!!!
            stream = core.createWriteStream()
            writeQueue := new Queue(((buf, next) ->
                log.info 'write quie'
                stream.write buf
                next()
                return
            ), concurrency: 10)
            mode = 'record'
            id = stream.key.toString('hex')
            feed := stream.feed
            self.postMessage do
                type: 'publication.info'
                id: id

        case \peer.start and feed
            log.info 'peer start!', ev.data.peerId
            id = ev.data.peerId
            swarms[id] = feed.replicate(
                live: true
                encrypted: false)
            swarms[id].on 'data', (buf) ->
                log.info 'peer start data!!!', buf
                self.postMessage do
                    type: 'peer.data'
                    peerId: id
                    buffer: buf
                return
        case \peer.data
            swarms[ev.data.peerId].write Buffer(ev.data.buffer)
        case \peer.end
            console.warn 'PEER END', ev.data.peerId
            swarms[ev.data.peerId].end()
        case \record.data and mode is 'record'
            seq = writeSeq++
            tobuf ev.data.blob, (buf) ->
                writeQueue.push seq, buf
                return
        case \subscription.start
            log \subscription-start!!! , ev

            stream = core.createReadStream ev.data.secret,
                live: true
            feed := stream.feed
            stream.on 'data', (buf) ->
                log.info 'XXXX GETTING STREAM DATA!!!'
                self.postMessage do
                    type: 'subscription.data'
                    index: ev.data.index
                    buffer: buf
                return

        case \publication.message
            log.info 'xxxxxxxxxxxx'
            log.info writeQueue
            log.info ev
            seq = writeSeq++
            writeQueue.push(seq, Buffer(ev.data.message))

