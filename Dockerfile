# ---- Stage 1: Build ----
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy Maven files & source
COPY pom.xml .
COPY src ./src

# Build Spring Boot JAR (skip tests for faster build)
RUN mvn clean package -DskipTests

# ---- Stage 2: Run ----
FROM openjdk:17-jdk-slim
WORKDIR /app

# Install required native libraries for OpenCV/ONNX
RUN apt-get update && apt-get install -y \
    libopencv-dev \
    libopenblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    libgfortran5 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libglib2.0-0 \
    libgtk2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy built JAR from build stage
COPY --from=build /app/target/attendance-system-1.0.0.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
