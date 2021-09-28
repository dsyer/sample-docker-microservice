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
$ ./target/thin/bin/java -cp ${CP} pl.piomin.microservices.person
.Application
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