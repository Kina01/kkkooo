# -------- BUILD STAGE --------
# Sử dụng Maven + Temurin JDK 21 để build
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy toàn bộ project vào container
COPY . .

# Build jar (bỏ test cho nhanh)
RUN mvn clean package -DskipTests


# -------- RUN STAGE --------
# Chạy bằng JRE 21 nhẹ hơn
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy file jar từ stage build
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# ENTRYPOINT chạy Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]
