
FROM node:22.5.1 as build

COPY . .


RUN yarn install


FROM node:22.5.1

COPY --from=build . .

EXPOSE 3005
CMD ["yarn", "start"]
