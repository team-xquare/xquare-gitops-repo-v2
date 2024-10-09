
FROM node:22.5.1 as build

COPY . .


RUN yarn build


FROM node:22.5.1

COPY --from=build . .

EXPOSE 3000
CMD ["yarn", "start"]
