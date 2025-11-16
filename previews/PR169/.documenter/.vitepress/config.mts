import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/Tidier.jl/previews/PR169/',// TODO: replace this in makedocs!
  title: 'Tidier.jl',
  description: "A VitePress Site",
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../1', // This is required for MarkdownVitepress to work correctly...
  head: [['link', { rel: 'icon', href: 'REPLACE_ME_DOCUMENTER_VITEPRESS_FAVICON' }]],
  ignoreDeadLinks: true,

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
{ text: 'Home', link: '/index' },
{ text: 'Get Started', collapsed: false, items: [
{ text: 'Installation', link: '/installation' },
{ text: 'A Simple Data Analysis', link: '/simple-analysis' },
{ text: 'From Data to Plots', link: '/simple-plotting' }]
 },
{ text: 'Changelog', link: '/news' },
{ text: 'FAQ', link: '/faq' }
]
,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Get Started', collapsed: false, items: [
{ text: 'Installation', link: '/installation' },
{ text: 'A Simple Data Analysis', link: '/simple-analysis' },
{ text: 'From Data to Plots', link: '/simple-plotting' }]
 },
{ text: 'Changelog', link: '/news' },
{ text: 'FAQ', link: '/faq' }
]
,
    editLink: { pattern: "https://https://github.com/TidierOrg/Tidier.jl/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/TidierOrg/Tidier.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
