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
RUN java -jar /opt/app/app.jar --thin.classpath --thin.root=/opt/app > /opt/app/classpath
RUN for f in $(cat /opt/app/classpath | tr ':' ' '); do jar tf $f | grep '.*\.class$' \
     | sed -e 's,/,.,g' -e 's/\.class//' | egrep -v module-info \
     | egrep -v META-INF; done > /opt/app/app.classlist

FROM alpine:latest
COPY --from=build  /springboot-runtime /opt/jdk
COPY --from=dependencies  /opt/app/repository /opt/app/repository
COPY --from=dependencies  /opt/app/app.jar /opt/app
COPY --from=dependencies  /opt/app/app.classlist /opt/app
COPY --from=dependencies  /opt/app/classpath /opt/app
ENV PATH=$PATH:/opt/jdk/bin
RUN java -Xshare:dump -XX:SharedClassListFile=/opt/app/app.classlist -XX:SharedArchiveFile=/opt/app/app.jsa \
     -cp $(cat /opt/app/classpath) pl.piomin.microservices.person.Application
CMD ["sh", "-c", "java -showversion -Xshare:on -XX:SharedArchiveFile=/opt/app/app.jsa -cp $(cat /opt/app/classpath) pl.piomin.microservices.person.Application"]