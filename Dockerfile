FROM node:24-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@10.30.0 --activate

# ------- Build API -------
FROM base AS build-api
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY api/package.json ./api/
COPY api/prisma ./api/prisma/
RUN pnpm install --frozen-lockfile --filter api...
COPY api ./api
RUN pnpm --filter api run build
RUN ls -la /app/api/dist

# ------- Build WEB -------
FROM base AS build-web
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY web/package.json ./web/
RUN pnpm install --frozen-lockfile --filter web...
COPY web ./web
RUN pnpm --filter web run build
RUN ls -la /app/web/.next

# ------- Production -------
FROM base AS production
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY nginx.conf /etc/nginx/nginx.conf

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY api/package.json ./api/
RUN pnpm install --frozen-lockfile --prod --ignore-scripts --filter api...
COPY --from=build-api /app/api/dist ./api/dist
COPY api/prisma ./api/prisma

COPY web/package.json ./web/
COPY --from=build-web /app/web/.next ./web/.next
COPY --from=build-web /app/web/public ./web/public
RUN pnpm install --frozen-lockfile --prod --ignore-scripts --filter web...

COPY start.sh ./start.sh
RUN chmod +x ./start.sh

EXPOSE 80

CMD ["./start.sh"]