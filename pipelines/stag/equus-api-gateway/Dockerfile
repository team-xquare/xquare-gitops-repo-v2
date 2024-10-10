FROM gradle:8-jdk17 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul

COPY --from=build /app//application-infrastructure/build/libs/application-infrastructure-0.0.1-SNAPSHOT.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
