
FROM node:22 AS build

COPY . .


RUN --mount=type=cache,target=/root/.npm \
    nest build


FROM node:22

COPY --from=build . .

EXPOSE 3306
CMD ["nest", "start"]
