FROM amazoncorretto:21 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test


FROM amazoncorretto:21

ENV TZ=Asia/Seoul

COPY --from=build /appmmm/build/libs /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
