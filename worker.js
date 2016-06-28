var hypercore = require('hypercore')
var level = require('level-browserify')
var core = hypercore(level('hypercore'))
var Queue = require('ordered-queue')
var sodium = require('chloride/browser')

var store = require('store')
// var boxes = require('pull-box-stream')
var hubs = ['http://localhost:8080']
console.log = function () {
}
var sender = sodium.crypto_box_keypair();
var receiver = sodium.crypto_box_keypair();

var keys = {
    "publicKey": "0e395f763a3769658438d48130bc191b2bf14e834971d1877cc6ccd710ab5b49",
    "secretKey": "5d84c549dc5d0598fb17c9249c5110e3b4c2eeb797f24511d3481535aaa6a572"
}

var nounce = '869587878685748576857463';

module.exports = function (self) {
    var mode = null
    var feed, writeQueue, writeSeq = 0
    var swarms = {}

    self.addEventListener('message', function (ev) {
        if (ev.data.type === 'record.start') {
            var stream = core.createWriteStream()
            // var encStream = boxes.createBoxStream('87968574678768594836574848796857467876859483657484123456');
            // console.log('wow')
            // console.log(encStream.pipe)
            // console.log(encStream)
            writeQueue = new Queue(function (buf, next) {

                var cipherMsg = sodium.crypto_box_easy(buf, nounce, Buffer(keys.publicKey, 'hex'), Buffer(keys.secretKey, 'hex'));
                // console.log(buf)
                // console.log(cipherMsg)
                stream.write(cipherMsg)
                next()
            }, {concurrency: 10})
            mode = 'record'
            var id = stream.key.toString('hex')
            feed = stream.feed
            self.postMessage({type: 'record.info', id: id})

        } else if (ev.data.type === 'peer.start' && feed) {
            var id = ev.data.peerId
            swarms[id] = feed.replicate({live: true, encrypted: true})
            swarms[id].on('data', function (buf) {
                console.log('SEND PEER', buf.length)
                self.postMessage({
                    type: 'peer.data',
                    peerId: id,
                    buffer: buf
                })
            })
        } else if (ev.data.type === 'peer.data') {
            swarms[ev.data.peerId].write(Buffer(ev.data.buffer))
        } else if (ev.data.type === 'peer.end') {
            swarms[ev.data.peerId].end()
        } else if (mode === 'record' && ev.data.type === 'record.data') {
            var seq = writeSeq++
            tobuf(ev.data.blob, function (buf) {
                writeQueue.push(seq, buf)
            })
        } else if (ev.data.type === 'play.stream') {
            var stream = core.createReadStream(ev.data.id, {
                live: true,
                start: ev.data.start,
                end: ev.data.end
            })
            feed = stream.feed
            stream.on('data', function (buf) {

                var plainBuffer = sodium.crypto_box_open_easy(buf, nounce, Buffer(keys.publicKey, 'hex'),
                    Buffer(keys.secretKey, 'hex'));

                self.postMessage({
                    type: 'play.data',
                    index: ev.data.index,
                    buffer: plainBuffer
                })
            })
        }
    })
}

function tobuf(blob, cb) {
    var r = new FileReader()
    r.addEventListener('loadend', function () {
        cb(Buffer(new Uint8Array(r.result)))
    })
    r.readAsArrayBuffer(blob)
}
