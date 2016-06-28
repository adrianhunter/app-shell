var path = require('path');

module.exports = {
  entry: [
    './tests/core.ls'
  ],
  output: {
    path: './tests',
    filename: 'core.js'
  },
  target:"web",
    "browser": { "fs": "empty" },
  
  node: {
    fs: "empty"
  },
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