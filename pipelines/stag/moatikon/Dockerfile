
FROM node:22.5.1 AS build

COPY . .


RUN npm install && npm run build


FROM node:22.5.1

COPY --from=build . .

EXPOSE 8765
CMD ["npm", "run", "start"]
