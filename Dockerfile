FROM node:20-alpine as base
MAINTAINER Jason

VOLUME /www
WORKDIR /www

RUN npm config set registry https://registry.npmmirror.com/
RUN npm get registry
RUN npm install -g pnpm
RUN pnpm config set registry https://registry.npmmirror.com/
RUN npm install -g pm2

FROM base as build
COPY . /www
RUN pnpm install && pnpm build:game
RUN cp /www/packages/game/dist /www/packages/backend/src/static

FROM build
EXPOSE 7788
CMD ["pm2","--no-daemon","start","pnpm","--name","star-angry","--","run","dev:backend"]

# docker build -t star-angry/server:1.0.0 .
# docker run --restart always -d -p 7788:7788 --name star-angry -v $(pwd)/config/:/www/config/ -v $(pwd)/game-data/:/www/packages/backend/dist/ star-angry/server:1.0.0
# docker stop star-angry
# docker rm star-angry
# docker rmi star-angry/server:1.0.0
# docker volume rm $(docker volume ls -qf dangling=true)
# docker rmi $(docker images -f "dangling=true" -q)
# docker logs -f --tail=100 star-angry
# docker exec -it star-angry /bin/sh