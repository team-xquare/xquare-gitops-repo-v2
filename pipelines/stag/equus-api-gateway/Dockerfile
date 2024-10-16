FROM amazoncorretto:17 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


FROM amazoncorretto:17

ENV TZ=Asia/Seoul

COPY --from=build /app/build/libs/Equus-Api-Gateway-0.0.1-SNAPSHOT.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
