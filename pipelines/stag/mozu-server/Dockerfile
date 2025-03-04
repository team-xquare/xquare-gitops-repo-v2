
FROM node:20.16 AS build

COPY . .


RUN --mount=type=cache,target=/root/.npm \
    npm install && npm run build


FROM node:20.16

COPY --from=build . .

EXPOSE 3000
CMD ["npm", "run", "start"]
