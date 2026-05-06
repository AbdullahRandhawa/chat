# ── Rentlyst Chat (React/Vite) – Dockerfile ─────────────────────────────────
# Stage 1: Build the Vite app
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Build static assets into /app/dist
RUN npm run build

# ── Stage 2: Serve with a lightweight static server ─────────────────────────
FROM node:22-alpine AS runner

WORKDIR /app

# Install 'serve' globally — tiny, production-ready static file server
RUN npm install -g serve

# Non-root user
RUN addgroup -S chat && adduser -S chat -G chat

# Copy only the built dist folder
COPY --from=builder /app/dist ./dist

USER chat

EXPOSE 4173

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:4173/ || exit 1

# serve -s = SPA mode (rewrite all 404s to index.html)
CMD ["serve", "-s", "dist", "-l", "4173"]
