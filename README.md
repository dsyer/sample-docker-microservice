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

The docker image is about 160MB.

(Original idea by @piomin.)