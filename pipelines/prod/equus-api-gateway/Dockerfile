FROM gradle:8-jdk17 AS build
ENV TZ=Asia/Seoul

COPY . .


RUN --mount=type=cache,target=/home/gradle/.gradle \
    ./gradlew build -x test --build-cache


COPY build/libs/Equus-Api-Gateway-0.0.1-SNAPSHOT.jar app.jar

FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul

COPY --from=build /app.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
