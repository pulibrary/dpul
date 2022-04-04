const { webpackConfig, merge } = require('@rails/webpacker')
const vueConfig =  require('./rules/vue')

const options = {
  resolve: {
      extensions: ['.vue', '.js', '.sass', '.scss', '.css', '.module.sass', '.module.scss', '.module.css', '.png', '.svg', '.gif', '.jpeg', '.jpg']
  }
}

module.exports = merge({}, webpackConfig, vueConfig, options)
