var getMedia = require('getusermedia')
var through = require('through2')
var webrtcSwarm = require('webrtc-swarm')
var signalhub = require('signalhub')
var onend = require('end-of-stream')

console.log = function (){};

var hubs = [ 'http://localhost:8080' ]

var Worker = require('webworkify')
var worker = Worker(require('./worker.js'))
worker.addEventListener('message', function (ev) {
  if (ev.data.type === 'record.info') {
    state.recordId = ev.data.id
    createSwarm(ev.data.id)
    update()
  } else if (state.playing && ev.data.type === 'play.data') {
    console.log('PLAY DATA', ev.data.buffer.length)
    playStreams[ev.data.index].write(Buffer(ev.data.buffer))
  } else if (ev.data.type === 'peer.data') {
    console.log('RECV PEER', ev.data.buffer.length)
    peers[ev.data.peerId].write(Buffer(ev.data.buffer))
  }
})

var html = require('yo-yo')
var root = document.querySelector('#content')

var state = {
  playId: null,
  recordId: null,
  videoSource: null,
  recording: false,
  playing: false,
  start_time: null
}

var recorder = null
var playStreamIndex = 0
var playStreams = {}
var peers = {}

window.addEventListener('hashchange', onhash)
if (/^#[0-9a-f]{16,}$/.test(location.hash)) onhash()

function onhash () {
  var h = location.hash.slice(1)
  if (/^[0-9a-f]{16,}$/.test(h)
  && h !== state.recordId && h !== state.playId) {
    var createReadStream = createPlayer(h)
    update()
  }
}

function createPlayer (id) {
  state.playId = id
  state.playing = true
  //var codec = 'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'
  //var codec = 'video/mp4; codecs="avc1.64001E"'
  var codec = 'video/webm; codecs="vp8"'
  var media = new MediaSource
  state.videoSource = URL.createObjectURL(media)
  media.addEventListener('sourceopen', onopen)
  update()

  worker.postMessage({ type: 'play.start', id: id })

  function onopen (ev) {
    console.log('OPEN')
    var source = media.addSourceBuffer(codec)
    source.addEventListener('update', function (ev) {
      if (queue.length > 0 && !source.updating) {
        source.appendBuffer(queue.shift())
      }
    })

    var queue = []
    var stream = createReadStream()
    stream.pipe(through(function (buf, enc, next) {
      if (source.updating || queue.length > 0) {
        queue.push(buf)
      } else {
        source.appendBuffer(buf)
      }
      next()
    }))
    createSwarm(id)
    setPlayerTime()
  }

  function createReadStream (opts) {
    if (!opts) opts = {}
    var index = playStreamIndex++
    playStreams[index] = through()
    worker.postMessage({
      type: 'play.stream',
      id: id,
      start: opts.start,
      end: opts.end,
      index: index
    })
    return playStreams[index]
  }
}

function update () {
  html.update(root, render(state))
}
update()

function render (state) {
  if (state.playId) return renderPlayer(state)
  else return renderRecorder(state)
}

function renderPlayer (state) {
  return html`<div>
    <video width="400" height="310" data-setup="{}" id="my-video" class="video-js"
      src=${state.videoSource} autoplay controls
    ></video>
  </div>`
}

function renderRecorder(state) {
  return html`<div id="content">
    <div>
      ${state.recordId
        ? html`<a href="#${state.recordId}?start_time=${state.start_time}">${state.recordId}</a>`
        : ''}
    </div>
    <div>
      ${state.recording
        ? html`<button class="ui button" onclick=${stopCast}>stop webcast</button>`
        : html`<button class="ui primary button" onclick=${startCast}>start webcast</button>`
      }
    </div>
    <div>
      <video width="400" height="300" src=${state.videoSource} autoplay>
      </video>
    </div>
  </div>`

  function startCast () {
    state.recording = true;
    state.start_time = new Date().getTime();
    if (recorder) {
      recorder.resume()
      return update()
    }
    worker.postMessage({ type: 'record.start' })

    getMedia({ video: true, audio: false }, function (err, media) {
      if (err) return console.error(err)
      state.videoSource = URL.createObjectURL(media)

      recorder = new MediaRecorder(media)
      state.mimeType = recorder.mimeType

      recorder.addEventListener('dataavailable', function (ev) {
        worker.postMessage({ type: 'record.data', blob: ev.data })
      })
      recorder.start(1000)
      update()
    })
  }
  function stopCast () {
    if (recorder) recorder.pause()
    state.recording = false
    update()
  }
}

function createSwarm (id) {
  var swarm = webrtcSwarm(signalhub('spellcast.' + id, hubs))
  swarm.on('peer', function (peer, peerId) {
    console.log('PEER', peerId)
    peers[peerId] = peer
    worker.postMessage({ type: 'peer.start', peerId: peerId })
    peer.on('data', function (buf) {
      console.log('getting peer data!')
      worker.postMessage({ type: 'peer.data', peerId: peerId, buffer: buf })
    })
    onend(peer, function () {
      worker.postMessage({ type: 'peer.end', peerId: peerId })
    })
  })
}


function setPlayerTime () {
  var search = searchToObject();

  if(search.start_time) {
    var player = document.getElementsByTagName('video')
    player.currentTime = new Date().getTime()-search.start_time/1000;
  }


}


function searchToObject() {
  var pairs = window.location.search.substring(1).split("&"),
      obj = {},
      pair,
      i;

  for ( i in pairs ) {
    if ( pairs[i] === "" ) continue;

    pair = pairs[i].split("=");
    obj[ decodeURIComponent( pair[0] ) ] = decodeURIComponent( pair[1] );
  }

  return obj;
}
