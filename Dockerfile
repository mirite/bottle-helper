FROM node:22.8-alpine AS node
FROM node AS deps
RUN mkdir -p /app
WORKDIR /app

ARG GHACCESS
ENV GHACCESS=$GHACCESS
COPY ./.yarn/releases ./.yarn/releases
COPY ./.yarnrc.yml .
COPY yarn.lock .
COPY package.json .
RUN yarn install

FROM node AS build
RUN corepack enable
RUN mkdir -p /app
WORKDIR /app
COPY --from=deps /app/.yarn/releases ./.yarn/releases
COPY --from=deps /app/.yarnrc.yml .
COPY --from=deps /app/package.json ./package.json
COPY --from=deps /app/yarn.lock ./yarn.lock
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

# Stage 2: Serve the deploy tool using Nginx
FROM nginx:alpine AS server

COPY --from=build /app/dist /usr/share/nginx/html
COPY apps/webview/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
