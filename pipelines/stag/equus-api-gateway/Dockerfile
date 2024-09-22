FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
COPY build/libs/Equus-Api-Gateway-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
