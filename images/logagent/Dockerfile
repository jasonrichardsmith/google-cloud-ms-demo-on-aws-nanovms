FROM node:16-alpine as build
WORKDIR /working
COPY . .
WORKDIR /working/images/logagent/
RUN npm i @sematext/logagent

FROM jasonrichardsmith/ops:0.1.28.4 as image
COPY --from=build /working/ /working/
WORKDIR /working
ENTRYPOINT ./scripts/logagent.sh
