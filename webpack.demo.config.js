var path = require('path');

module.exports = {
  entry: [
    // setup the hot mobule loading
    // our entry file
    './example/src/example2.ls'
  ],
  output: {
    path: './example/public',
    filename: 'example.js'
  },
  target:"web",
    "browser": { "fs": "empty" },
  
  node: {
    fs: "empty"
  },
  //  devtool: "source-map",
  module: {
    preLoaders: [
      { test: /\.json$/, loader: 'json' },
    ],
    loaders: [
      { test: /\.ls$/, loader: "livescript" }
    ],
      postLoaders: [
      {
        include: [
          path.resolve(__dirname, 'node_modules/level-browserify'),
          path.resolve(__dirname, 'node_modules/chloride'),
          path.resolve(__dirname, 'node_modules/webrtc-swarm'),
          path.resolve(__dirname, 'node_modules/webworkify'),
          path.resolve(__dirname, 'node_modules/memdb'),
          path.resolve(__dirname, 'node_modules/hyperlog-sodium'),
          path.resolve(__dirname, 'node_modules/hypercore'),
          path.resolve(__dirname, 'node_modules/hyperlog'),
          
        ],
        loader: 'transform?brfs'
      }
    ]
  },
  resolve: {
    extensions: ["", ".ls", ".js"]
  }
}