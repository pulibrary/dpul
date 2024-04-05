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

import {createApp} from "vue";
import lux from "lux-design-system";
import "lux-design-system/dist/style.css";
import Initializer from '@/dpul/pom_boot'

const app = createApp({});
const createMyApp = () => createApp(app);

document.addEventListener ('DOMContentLoaded', () => {
      const elements = document.getElementsByClassName('lux')
      for(let i = 0; i < elements.length; i++){
          createMyApp().use(lux)
          .mount(elements[i]);
      }

  window.pom = new Initializer()
})
