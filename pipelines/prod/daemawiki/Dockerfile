FROM gradle:8-jdk21 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


FROM openjdk:21-jdk-slim
ENV TZ=Asia/Seoul

COPY --from=build /app/build/libs/*.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
