
FROM node:22.5.1 AS build

COPY . .


RUN --mount=type=cache,target=/root/.npm \
    npm install && npm run build


FROM node:22.5.1

COPY --from=build . .

EXPOSE 8764
CMD ["npm", "run", "start"]
