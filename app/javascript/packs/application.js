/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue/dist/vue.esm'
import system from 'lux-design-system'
import 'lux-design-system/dist/system/system.css'

Vue.use(system)

document.addEventListener('DOMContentLoaded', () => {
  var elements = document.getElementsByClassName('lux')
  for(var i = 0; i < elements.length; i++){
    new Vue({
      el: elements[i]
    })
  }
})

