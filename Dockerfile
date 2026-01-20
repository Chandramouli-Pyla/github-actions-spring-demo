# --------- Build stage ---------
FROM maven:3.9.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Copy source code and build the jar
COPY src ./src
RUN mvn -B -DskipTests package

# --------- Run stage ---------
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the fat jar from the builder image
COPY --from=builder /app/target/*.jar app.jar

# Cloud Run (and our docker run) will use PORT env variable; default 8080
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
