FROM openjdk:17-jdk-slim as build
ENV TZ=Asia/Seoul

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


COPY /build/libs/xquare-infra-0.0.1-SNAPSHOT.jar app.jar

FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul

COPY --from=build /app.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
