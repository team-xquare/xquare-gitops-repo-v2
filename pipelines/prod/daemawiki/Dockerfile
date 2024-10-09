FROM openjdk:21-jdk-slim as build
ENV TZ=Asia/Seoul


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


COPY /build/libs/*.jar app.jar

FROM openjdk:21-jdk-slim
ENV TZ=Asia/Seoul

COPY --from=build /app.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
