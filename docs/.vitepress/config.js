export default {
  themeConfig: {
    siteTitle: 'SillyTavern-Termux', // 顶栏站点标题
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
