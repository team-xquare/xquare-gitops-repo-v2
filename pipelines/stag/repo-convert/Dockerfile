
FROM node:22.5.1 AS build

COPY . .


RUN yarn install


FROM node:22.5.1

COPY --from=build . .

EXPOSE 3005
CMD ["yarn", "start"]
