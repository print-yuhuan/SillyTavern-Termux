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

const base = import.meta.env.BASE_URL; // 自动获取 base
const images = [
  { src: `${base}sillytavern/preview1.jpg`, alt: '预览1' },
  { src: `${base}sillytavern/preview2.jpg`, alt: '预览2' },
  { src: `${base}sillytavern/preview3.jpg`, alt: '预览3' },
  { src: `${base}sillytavern/preview4.jpg`, alt: '预览4' },
  { src: `${base}sillytavern/preview5.jpg`, alt: '预览5' },
  { src: `${base}sillytavern/preview6.jpg`, alt: '预览6' },
];
</script>

<style scoped>
.my-swiper {
  display: flex;
  justify-content: center;
}
</style>
