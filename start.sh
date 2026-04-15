#!/bin/sh

# Inicia o backend
cd /app/api && node dist/index.js &

# Inicia o frontend
cd /app/web && pnpm start &

# Inicia o nginx
nginx -g "daemon off;"
