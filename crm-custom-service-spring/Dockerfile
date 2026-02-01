# Multi-stage build for Spring Boot service
FROM maven:3.9-eclipse-temurin-21-alpine AS build

# Set working directory
WORKDIR /app

# Copy all files
COPY pom.xml .
COPY src ./src

# Build the application (this will download dependencies)
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/crm-custom-service-*.jar app.jar

# Expose Spring Boot port
EXPOSE 3001

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
