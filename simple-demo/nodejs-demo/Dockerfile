# Using Paketo Buildpacks for Cloud Native builds
FROM paketobuildpacks/builder-jammy-base:latest AS builder
WORKDIR /workspace
COPY . .

# Runtime stage
FROM node:18-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 8082

ENV NODE_ENV=production
ENV PORT=8082

CMD ["node", "src/server.js"]
