FROM openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
COPY /build/libs/BE-COCO-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
