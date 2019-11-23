"use strict";

const path = require("path");

const webpack = require("webpack");

const isWebpackDevServer = process.argv.some(
  a => path.basename(a) === "webpack-dev-server"
);

const isWatch = process.argv.some(a => a === "--watch");

const plugins =
  isWebpackDevServer || !isWatch
    ? []
    : [
        function() {
          this.plugin("done", function(stats) {
            process.stderr.write(stats.toString("errors-only"));
          });
        }
      ];
module.exports = {
  devtool: "eval-source-map",

  devServer: {
    contentBase: ".",
    port: 4008,
    stats: "errors-only"
  },

  entry: "./src/index.js",

  output: {
    path: path.resolve(__dirname, "public"),
    pathinfo: true,
    filename: "egg.js"
  },

  module: {
    rules: [
      {
        test: /\.purs$/,
        use: [
          {
            loader: "purs-loader",
            options: {
              src: ["src/**/*.purs"],
              bundle: false,
              watch: isWebpackDevServer || isWatch,
              pscIde: false,
              spago: true,
              psc: "psa"
            }
          }
        ]
      }
    ]
  },

  resolve: {
    modules: ["node_modules", "bower_components"],
    extensions: [".purs", ".js"]
  },

  plugins: [
    new webpack.LoaderOptionsPlugin({
      debug: true
    })
  ].concat(plugins)
};
