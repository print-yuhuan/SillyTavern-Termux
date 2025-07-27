<template>
  <div class="my-swiper">
    <swiper
      :modules="[Autoplay, Pagination]"
      :loop="true"
      :autoplay="{ delay: 3000, disableOnInteraction: false }"
      :pagination="{ clickable: true }"
      :slides-per-view="1"
      :space-between="20"
      style="width: 360px; max-width: 90vw;"
    >
      <swiper-slide v-for="(img, i) in images" :key="i">
        <img :src="img.src" :alt="img.alt" style="width:100%;border-radius:22px;box-shadow:0 4px 18px #eee;" />
      </swiper-slide>
      <div class="swiper-pagination" slot="pagination"></div>
    </swiper>
  </div>
</template>

<script setup>
import { Swiper, SwiperSlide } from 'swiper/vue';
import { Autoplay, Pagination } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';

const images = [
  { src: '/preview1.jpg', alt: '预览1' },
  { src: '/preview2.jpg', alt: '预览2' },
  { src: '/preview3.jpg', alt: '预览3' },
];
</script>

<style scoped>
.my-swiper {
  display: flex;
  justify-content: center;
}
</style>
