
FROM node:22.5.1 as build

COPY . .


RUN npm i


FROM node:22.5.1

COPY --from=build . .

EXPOSE 3000
CMD ["node", "app.js"]
