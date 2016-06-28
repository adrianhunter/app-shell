var path = require('path');

var webpack = require('webpack');

var PROD = JSON.parse(process.env.PROD_ENV || '0');


module.exports = {
  entry: [
    // setup the hot mobule loading
    // our entry file
    './src/app-shell.ls'
  ],
  output: {
    path: './lib',
    filename: 'app-shell.js'
  },
  node: {
    fs: "empty"
  },
  plugins: PROD ? [
     new webpack.optimize.UglifyJsPlugin({
      compress: { warnings: false }
    })
  ]: [

  ],
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
        // include: [
        //   path.resolve(__dirname, 'node_modules/level-browserify'),
        //   path.resolve(__dirname, 'node_modules/chloride'),
        //   path.resolve(__dirname, 'node_modules/webrtc-swarm'),
        //   path.resolve(__dirname, 'node_modules/webworkify'),
        //   path.resolve(__dirname, 'node_modules/memdb'),
        //   path.resolve(__dirname, 'node_modules/hyperlog-sodium'),
        //   path.resolve(__dirname, 'node_modules/hypercore'),
        //   path.resolve(__dirname, 'node_modules/hyperlog'),
          
        // ],
        loader: 'transform?brfs'
      }
    ]
  },
  resolve: {
    extensions: ["", ".ls", ".js"]
  }
}