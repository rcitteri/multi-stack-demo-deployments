# Multi-stage Dockerfile for Spring Boot applications
# Builds both the main application and the database initializer

# Stage 1: Build main application
FROM maven:3.9-eclipse-temurin-25 AS builder-app
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build main app
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Build database initializer from separate project
FROM maven:3.9-eclipse-temurin-25 AS builder-initializer
WORKDIR /app

# Copy initializer pom.xml and download dependencies
COPY initializer/pom.xml .
RUN mvn dependency:go-offline -B

# Copy initializer source code and build
COPY initializer/src ./src
RUN mvn clean package -DskipTests

# Stage 3: Runtime for main application
FROM eclipse-temurin:25-jre-alpine AS app-runtime
WORKDIR /app

# Add non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy main app JAR from builder stage
COPY --from=builder-app /app/target/cloud-native-chat-demo-*.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Stage 4: Runtime for database initializer
FROM eclipse-temurin:25-jre-alpine AS initializer-runtime
WORKDIR /app

# Add non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy initializer JAR from builder stage
COPY --from=builder-initializer /app/target/cloud-native-chat-initializer-*.jar app.jar

# No health check needed (one-off process)
# Run the initializer (exits after completion)
ENTRYPOINT ["java", "-jar", "app.jar"]
