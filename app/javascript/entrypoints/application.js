// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')
console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
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
