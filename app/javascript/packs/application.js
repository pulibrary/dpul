/* eslint no-console:0 */
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue/dist/vue.esm'
import system from 'lux-design-system'
import 'lux-design-system/lib/system/system.css'
// import TurbolinksAdapter from 'vue-turbolinks'

Vue.use(system)
// Vue.use(TurbolinksAdapter)

// create the LUX app and mount it to wrappers with class="lux"
// document.addEventListener('turbolinks:load', () => {
document.addEventListener('DOMContentLoaded', () => {
  var elements = document.getElementsByClassName('lux')
  for(var i = 0; i < elements.length; i++){
    new Vue({
      el: elements[i]
    })
  }
})
