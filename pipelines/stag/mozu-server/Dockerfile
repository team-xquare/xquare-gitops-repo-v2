
FROM node:20.16 AS build

COPY . .


RUN nest start


FROM node:20.16

COPY --from=build . .

EXPOSE 3000
CMD ["nest", "start"]
