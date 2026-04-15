FROM node:24-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@10.30.0 --activate
WORKDIR /app

# Copia arquivos do monorepo raiz
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copia o workspace da api
COPY api/package.json ./api/
COPY api/prisma ./api/prisma/

# ------- Dependencies -------
FROM base AS deps
RUN pnpm install --frozen-lockfile --filter api...

# ------- Build -------
FROM deps AS build
COPY api ./api
RUN pnpm --filter api run build && cp -r api/src/generated api/dist/generated

# ------- Production -------
FROM base AS production
RUN pnpm install --frozen-lockfile --prod --ignore-scripts --filter api...
COPY --from=build /app/api/dist ./api/dist
WORKDIR /app/api
CMD ["node", "dist/index.js"]