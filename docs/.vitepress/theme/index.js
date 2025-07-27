import DefaultTheme from 'vitepress/theme'
import SwiperCarousel from './SwiperCarousel.vue'

export default {
  ...DefaultTheme,
  enhanceApp({ app }) {
    app.component('SwiperCarousel', SwiperCarousel)
  }
}
