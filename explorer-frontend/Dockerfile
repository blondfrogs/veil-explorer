# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Build arguments for environment variables needed at build time
ARG NUXT_PUBLIC_SITE_URL=http://explorer.veil.zelcore.io
ARG NUXT_PUBLIC_I18N_BASE_URL=http://explorer.veil.zelcore.io
ARG NUXT_PUBLIC_BASE_URL=http://explorer.veil.zelcore.io
ARG NUXT_PUBLIC_CHAIN_DEFAULT=main
ARG NUXT_PUBLIC_CHAIN_APIS=[{"name": "main", "path": "http://api.veil.zelcore.io/api"}]
ARG NUXT_PUBLIC_RECENT_BLOCKS_COUNT=5
ARG NUXT_PUBLIC_BLOCKS_PER_PAGE=15
ARG NUXT_PUBLIC_TXS_PER_PAGE=15
ARG NUXT_PUBLIC_MAX_BLOCK_WEIGHT=4000000
ARG NUXT_PUBLIC_SYNC_NOTICE_CASE=15
ARG NUXT_PUBLIC_COOKIE_SAVE_DAYS=90

# Set environment variables for build
ENV NUXT_PUBLIC_SITE_URL=$NUXT_PUBLIC_SITE_URL
ENV NUXT_PUBLIC_I18N_BASE_URL=$NUXT_PUBLIC_I18N_BASE_URL
ENV NUXT_PUBLIC_BASE_URL=$NUXT_PUBLIC_BASE_URL
ENV NUXT_PUBLIC_CHAIN_DEFAULT=$NUXT_PUBLIC_CHAIN_DEFAULT
ENV NUXT_PUBLIC_CHAIN_APIS=$NUXT_PUBLIC_CHAIN_APIS
ENV NUXT_PUBLIC_RECENT_BLOCKS_COUNT=$NUXT_PUBLIC_RECENT_BLOCKS_COUNT
ENV NUXT_PUBLIC_BLOCKS_PER_PAGE=$NUXT_PUBLIC_BLOCKS_PER_PAGE
ENV NUXT_PUBLIC_TXS_PER_PAGE=$NUXT_PUBLIC_TXS_PER_PAGE
ENV NUXT_PUBLIC_MAX_BLOCK_WEIGHT=$NUXT_PUBLIC_MAX_BLOCK_WEIGHT
ENV NUXT_PUBLIC_SYNC_NOTICE_CASE=$NUXT_PUBLIC_SYNC_NOTICE_CASE
ENV NUXT_PUBLIC_COOKIE_SAVE_DAYS=$NUXT_PUBLIC_COOKIE_SAVE_DAYS

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Runtime stage
FROM node:20-alpine
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy built application
COPY --from=build /app/.output ./.output
COPY --from=build /app/package*.json ./

# Create a non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nuxtjs -u 1001 && \
    chown -R nuxtjs:nodejs /app

USER nuxtjs

# Expose port
EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

CMD ["node", ".output/server/index.mjs"]
