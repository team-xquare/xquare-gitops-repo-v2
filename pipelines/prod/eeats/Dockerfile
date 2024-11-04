
FROM node:22.5.1 AS build

COPY . .


RUN npm run build


FROM node:22.5.1

COPY --from=build . .

EXPOSE 3000
CMD ["npm", "run", "start"]
