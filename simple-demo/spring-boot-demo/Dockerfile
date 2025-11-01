# Using Paketo Buildpacks for Cloud Native builds
# This Dockerfile uses multi-stage build with Paketo builder

FROM paketobuildpacks/builder-jammy-base:latest AS builder
WORKDIR /workspace
COPY . .
RUN /cnb/lifecycle/creator -app=/workspace -buildpacks=/cnb/buildpacks -layers=/layers -platform=/platform

# Runtime stage
FROM paketobuildpacks/run-jammy-base:latest
COPY --from=builder /workspace/app /app
WORKDIR /app

EXPOSE 8080

ENV PORT=8080
ENV JAVA_OPTS="-Xmx512m -Xms256m"

CMD ["java", "-jar", "app.jar"]
