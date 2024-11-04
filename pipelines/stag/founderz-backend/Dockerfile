FROM amazoncorretto:21 AS build
ENV TZ=Asia/Seoul

WORKDIR /app

COPY . .


RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build -x test


FROM amazoncorretto:21

ENV TZ=Asia/Seoul

COPY --from=build /app/founderz-boot/build/libs/founderz-boot-0.0.1-SNAPSHOT.jar /app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
