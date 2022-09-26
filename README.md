# Spring Boot Container with JLink

Here's how I computed the modules for `jlink`:

```
$ CP=`java -jar target/sample-docker-microservice-1.0-SNAPSHOT.jar --thin.classpath`
$ MODS=`jdeps --ignore-missing-deps --multi-release 17 --print-module-deps --class-path ${CP} target/classes/pl/piomin/microservices/person/Application.class`
```

Then you can create a `jlink` binary distro like this:

```
$ jlink --compress=2 --module-path ${JAVA_HOME}/jmods --add-modules "${MODS}" --no-header-files --no-man-pages --output target/thin
```

Run the app:

```
$ ./target/thin/bin/java -cp ${CP} pl.piomin.microservices.person.Application
```

The `Dockerfile` in the root of the project does the last bit for you and takes a step further by also setting up App CDS.

The docker image is about 160MB:

```
Cmp   Size  Command                                                                       
    5.6 MB  FROM 695e5153d90d6a4                                                          
     65 MB  COPY /springboot-runtime /opt/jdk # buildkit                                  
     31 MB  COPY /opt/app/repository /opt/app/repository # buildkit                       
     13 kB  COPY /opt/app/app.jar /opt/app # buildkit                                     
    691 kB  COPY /opt/app/app.classlist /opt/app # buildkit                               
    4.1 kB  COPY /opt/app/classpath /opt/app # buildkit                                   
     69 MB  RUN /bin/sh -c java -Xshare:dump -XX:SharedClassListFile=/opt/app...
```

The biggest chunks in there are:

* Java runtime, 65MB
* Jar files, 31MB (could probably be slimmed down)
* CDS cache, 69MB

(Original idea by @piomin.)

## Modules Used

The `MODS` generated above from `jdeps` looks like quite a long list:

```
java.base,java.desktop,java.instrument,java.management,java.naming,java.prefs,java.rmi,java.scripting,java.sql,jdk.httpserver,jdk.jfr,jdk.unsupported
```

Spring 6 will get rid of `java.desktop` (the Java Beans dependency). You can slim that down to

```
java.base,java.desktop
```

and get an app to run with warnings (because `java.management` is missing).

## Older Notes

Before Spring Boot 2.7 without `java.naming` you get errors in Spring:

```
Caused by: java.lang.NoClassDefFoundError: javax/naming/NamingException
        at org.springframework.context.annotation.CommonAnnotationBeanPostProcessor.<init>(CommonAnnotationBeanPostProcessor.java:177) ~[spring-context-5.3.10.jar:5.3.10]
```

The `pom.xml` excludes `snakeyaml`. If you don't do that you also need `java.logging`.