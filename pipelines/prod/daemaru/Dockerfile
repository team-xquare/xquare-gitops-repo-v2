FROM amazoncorretto:17 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build


FROM amazoncorretto:17

ENV TZ=Asia/Seoul

COPY --from=build /appdaemaru-backend /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
