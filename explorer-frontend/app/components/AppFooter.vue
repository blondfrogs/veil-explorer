<template>
  <footer
    class="
      relative
      shadow
      p-6
      text-sm text-center text-gray-600
      bg-gray-50
      dark:text-gray-300 dark:bg-gray-800
    "
  >
    <div class="max-w-7xl w-full mx-auto">
      <div class="flex flex-col md:flex-row justify-between flex-wrap">
        <div class="flex flex-col md:flex-row items-start">
          <div class="font-semibold uppercase mx-2">
            {{ t("Footer.RelatedWebsites") }}:
          </div>
          <div class="mx-2 my-2 md:my-0">
            <a
              :href="veilProjectUrl" target="blank" class="
                text-sky-700
                dark:text-sky-400
                hover:underline
                underline-offset-4
              "
            >Veil Project</a>
          </div>
          <div class="mx-2 my-2 md:my-0">
            <a
              :href="veilStatsUrl" target="blank" class="
                text-sky-700
                dark:text-sky-400
                hover:underline
                underline-offset-4
              "
            >Veil Stats</a>
          </div>
          <div class="mx-2 my-2 md:my-0">
            <a
              :href="veilToolsUrl" target="blank" class="
                text-sky-700
                dark:text-sky-400
                hover:underline
                underline-offset-4
              "
            >Veil Tools</a>
          </div>
          <div class="mx-2 my-2 md:my-0">
            <a
              :href="githubRepoUrl" target="blank" class="
                text-sky-700
                dark:text-sky-400
                hover:underline
                underline-offset-4
              "
            >Github</a>
          </div>
        </div>
        <div class="text-left mx-2 mt-4 md:mt-0 md:flex-center">
          &copy; VEIL-PROJECT 2025
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const { t } = useI18n();
const config = useRuntimeConfig();

// Get external links from configuration
const veilProjectUrl = config.public.veilProjectUrl;
const veilStatsUrl = config.public.veilStatsUrl;
const veilToolsUrl = config.public.veilToolsUrl;
const githubRepoUrl = config.public.githubRepoUrl;
</script>