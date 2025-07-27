export default {
  base: process.env.VITEPRESS_BASE || '/SillyTavern-Termux/', // 优先使用环境变量，否则默认GitHub仓库名
  themeConfig: {
    siteTitle: 'SillyTavern-Termux',
    nav: [
      { text: '主页', link: '/' },
      { text: '开始', link: '/guide/quickstart' }
    ],
    sidebar: [
      { text: '返回主页', link: '/' },
      { text: '快速开始', link: '/guide/quickstart' },
      { text: '功能详解', link: '/guide/menu' },
      { text: '插件扩展', link: '/guide/plugins' },
      { text: '常见问题', link: '/guide/faq' },
      { text: '关于作者', link: '/guide/about' }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/print-yuhuan/SillyTavern-Termux' }
    ]
  }
}
