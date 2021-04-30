FROM alpine:latest AS build
ENV JAVA_HOME /opt/jdk/jdk-17
ENV PATH $JAVA_HOME/bin:$PATH

ADD https://download.java.net/java/early_access/alpine/14/binaries/openjdk-17-ea+14_linux-x64-musl_bin.tar.gz /opt/jdk/
RUN tar -xzvf /opt/jdk/openjdk-17-ea+14_linux-x64-musl_bin.tar.gz -C /opt/jdk/
RUN ["jlink", "--compress=2", \
     "--module-path", "/opt/jdk/jdk-17/jmods/", \
     "--add-modules", "java.base,java.desktop,java.instrument,java.management,java.naming,java.prefs,java.rmi,java.scripting,java.security.jgss,java.security.sasl,java.sql,jdk.httpserver,jdk.jfr,jdk.unsupported", \
     "--no-header-files", "--no-man-pages", \
     "--output", "/springboot-runtime"]

FROM alpine:latest AS dependencies
COPY --from=build  /opt/jdk/jdk-17 /opt/jdk
ENV JAVA_HOME /opt/jdk
ENV PATH $JAVA_HOME/bin:$PATH
COPY target/sample-docker-microservice-1.0-SNAPSHOT.jar /opt/app/app.jar
RUN java -jar /opt/app/app.jar --thin.dryrun --thin.root=/opt/app

FROM alpine:latest
COPY --from=build  /springboot-runtime /opt/jdk
COPY --from=dependencies  /opt/app/repository /opt/app/repository
COPY --from=dependencies  /opt/app/app.jar /opt/app
ENV PATH=$PATH:/opt/jdk/bin
CMD ["sh", "-c", "java -showversion -cp $(java -jar /opt/app/app.jar --thin.classpath --thin.root=/opt/app) pl.piomin.microservices.person.Application"]