FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
COPY /build/libs/Equus-User-0.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
