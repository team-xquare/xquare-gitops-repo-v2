
FROM node:20.16 AS build

COPY . .


RUN yarn && yarn build


FROM node:20.16

COPY --from=build . .

EXPOSE 3000
CMD ["nest", "start"]
