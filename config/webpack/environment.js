const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const webpack = require('webpack')

environment.loaders.prepend('scss', {
  test: /\.(scss)$/,
    use: [
    {
      loader: 'style-loader', // inject CSS to page
    }, {
      loader: 'css-loader', // translates CSS into CommonJS modules
    }, {
      loader: 'sass-loader' // compiles Sass to CSS
    }]
})

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: 'popper.js'
  })
)

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment
