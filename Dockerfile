# STAGE: Build
FROM gradle:4.9.0-jdk8-alpine as builder

# Create Working Directory
ENV BUILD_DIR=/home/gradle/app/
RUN mkdir $BUILD_DIR
WORKDIR $BUILD_DIR

# Download Dependencies
COPY build.gradle $BUILD_DIR
RUN gradle build -x :bootRepackage -x test --continue

# Copy Code Over and Build jar
COPY src src
RUN gradle build -x test

# STAGE: Deploy
FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.7

# OPTIONAL: Install Extra Packages
#RUN apk --no-cache update \
# && apk add jq bash bc ca-certificates curl \
# && update-ca-certificates

# Create app directory
ENV APP_HOME=/home/jboss/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Copy jar file over from builder stage
COPY --from=builder /home/gradle/app/build/libs/micro-orders-0.0.1.jar $APP_HOME
RUN mv ./micro-orders-0.0.1.jar app.jar

COPY startup.sh startup.sh

EXPOSE 8084 8094
ENTRYPOINT ["./startup.sh"]