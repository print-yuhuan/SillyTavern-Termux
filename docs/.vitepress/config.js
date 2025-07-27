export default {
  base: process.env.VITEPRESS_BASE || '/SillyTavern-Termux/',
  themeConfig: {
    siteTitle: 'SillyTavern-Termux',
    outline: false,
    nav: [
      { text: '主页', link: '/' },
      { text: '开始', link: '/guide/sillytavern/quickstart' }
    ],
    sidebar: [
      { text: '返回主页', link: '/' },
      {
        text: '酒馆部署',
        collapsible: true,
        collapsed: true,
        items: [
          { text: '快速开始', link: '/guide/sillytavern/quickstart' },
          { text: '功能详解', link: '/guide/sillytavern/menu' },
          { text: '插件扩展', link: '/guide/sillytavern/plugins' },
          { text: '常见问题', link: '/guide/sillytavern/faq' }
        ]
      },
      {
        text: '轮询部署',
        collapsible: true,
        collapsed: true,
        items: [
          { text: '轮询部署', link: '/guide/hajimi/polling' }
        ]
      },
      {
        text: '配置保活',
        collapsible: true,
        collapsed: true,
        items: [
          { text: '保活配置', link: '/guide/cronjob/keepalive' }
        ]
      },
      { text: '关于作者', link: '/guide/about' }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/print-yuhuan/SillyTavern-Termux' }
    ]
  }
}
