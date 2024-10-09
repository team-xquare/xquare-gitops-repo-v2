
FROM node:22.5.1 as build


RUN yarn install


COPY . .

FROM node:22.5.1

COPY --from=build . .

EXPOSE 3005
CMD ["yarn", "start"]
