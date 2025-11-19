// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  compatibilityDate: "2025-07-15",
  future: {
    compatibilityVersion: 4,
  },
  runtimeConfig: {
    public: {
      site: {
        url: process.env.NUXT_PUBLIC_SITE_URL! as string,
      },
      baseUrl: process.env.NUXT_PUBLIC_BASE_URL! as string,
      chainDefault: process.env.NUXT_PUBLIC_CHAIN_DEFAULT! as string,
      chainApis: JSON.parse(process.env.NUXT_PUBLIC_CHAIN_APIS! as string),
      recentBlocksCount: Number.parseInt(process.env.NUXT_PUBLIC_RECENT_BLOCKS_COUNT!),
      blocksPerPage: Number.parseInt(process.env.NUXT_PUBLIC_BLOCKS_PER_PAGE!),
      txsPerPage: Number.parseInt(process.env.NUXT_PUBLIC_TXS_PER_PAGE!),
      maxBlockWeight: Number.parseInt(process.env.NUXT_PUBLIC_MAX_BLOCK_WEIGHT!),
      syncNoticeCase: Number.parseInt(process.env.NUXT_PUBLIC_SYNC_NOTICE_CASE!),
      cookieSaveDays: Number.parseInt(process.env.NUXT_PUBLIC_COOKIE_SAVE_DAYS!),
      // External links
      veilProjectUrl: process.env.NUXT_PUBLIC_VEIL_PROJECT_URL! as string,
      veilStatsUrl: process.env.NUXT_PUBLIC_VEIL_STATS_URL! as string,
      veilToolsUrl: process.env.NUXT_PUBLIC_VEIL_TOOLS_URL! as string,
      githubRepoUrl: process.env.NUXT_PUBLIC_GITHUB_REPO_URL! as string,
      internalApiUrl: process.env.NUXT_PUBLIC_INTERNAL_API_URL! as string,
    },
  },
  app: {
    pageTransition: { name: "page", mode: "out-in" },
    head: {
      templateParams: {
        separator: "-",
      },
      titleTemplate: "%siteName %separator %s",
    },
  },
  modules: ["@nuxt/image", "@nuxtjs/i18n", "@nuxtjs/tailwindcss", "@nuxtjs/seo", "@nuxt/eslint"],
  routeRules: {
    "/tx/**": {
      redirect: {
        to: "/main/tx/**",
        statusCode: 301,
      },
    },
    "/block/**": {
      redirect: {
        to: "/main/block/**",
        statusCode: 301,
      },
    },
    "/blocks/**": {
      redirect: {
        to: "/main/blocks/**",
        statusCode: 301,
      },
    },
    "/block-height/**": {
      redirect: {
        to: "/main/block-height/**",
        statusCode: 301,
      },
    },
    "/tx-stats/**": {
      redirect: {
        to: "/main/tx-stats/**",
        statusCode: 301,
      },
    },
    "/unconfirmed-tx/**": {
      redirect: {
        to: "/main/unconfirmed-tx/**",
        statusCode: 301,
      },
    },
  },
  i18n: {
    locales: [
      {
        name: "English",
        code: "en",
        language: "en-US",
        file: "en.ts",
      },
      {
        name: "Русский",
        code: "ru",
        language: "ru-RU",
        file: "ru.ts",
      },
    ],
    defaultLocale: "en",
    langDir: "localization",
    strategy: "prefix_except_default",
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: "lang",
      redirectOn: "root",
      alwaysRedirect: false,
    },
    baseUrl: process.env.NUXT_I18N_BASE_URL! as string,
  },
  image: {
    format: ["webp", "png"],
    provider: "ipx",
    quality: 100,
    ipx: {
      modifiers: {
        format: "webp",
        quality: 100,
      },
    },
  },
  seo: {
    redirectToCanonicalSiteUrl: process.env.NODE_ENV !== "development",
  },
  site: {
    url: process.env.NUXT_PUBLIC_SITE_URL! as string,
  },
  schemaOrg: {
    identity: {
      type: "Organization",
      name: "Veil Project",
      url: process.env.NUXT_PUBLIC_VEIL_PROJECT_URL! as string,
      logo: `${process.env.NUXT_PUBLIC_SITE_URL!}/icon-192x192-light.png`,
    },
  },
  css: ["~/assets/css/tailwind.css", "~/assets/css/common.css"],
  /* alias: {
        "chart.js": "chart.js/dist/chart.js",
    }, */
  build: {
    transpile: [
      "@heroicons/vue",
      "chart.js",
    ],
  },
  typescript: {
    typeCheck: true,
    strict: true,
  },
});