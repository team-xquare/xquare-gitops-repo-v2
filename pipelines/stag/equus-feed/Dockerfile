FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test --build-cache


COPY /build/libs/Equus-Feed-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
