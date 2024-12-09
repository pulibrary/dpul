import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import autoprefixer from 'autoprefixer';
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue()
  ],
  resolve: {
    alias: {
      'vue': 'vue/dist/vue.esm-bundler',
    }
  },
  css: {
    postcss: {
      plugins: [
        autoprefixer,
      ],
    },
  }
});
