
FROM node:22.5.1 as build


RUN npm install


COPY . .

FROM node:22.5.1

COPY --from=build . .

EXPOSE 3000
CMD ["node", "app.js"]
