const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const fs = require('fs');  // Node.jsの組み込みモジュール

module.exports = {
    mode: "production",
    entry: "./scripts/AtDocumentStart.js",
    output: {
        path: path.resolve(__dirname, 'Sources/ReadabilityUI/Resources'),
        filename: '[name].js'
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: ['css-loader', 'raw-loader']
        }
      ]
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: './scripts/Reader.html',
        filename: 'Reader.html',
        inject: false,
        templateParameters: {
          css: fs.readFileSync('./scripts/Reader.css', 'utf8') // fs.readFileSyncを使用
        }
      })
    ]
};
