FROM amazoncorretto:17-alpine-jdk

ARG USER
ARG USER_ID
ARG USER_GID

RUN (addgroup --gid "${USER_GID}" "${USER}" || echo "No groupadd needed") && \
    adduser \
     --disabled-password \
      --uid ${USER_ID} \
      --ingroup ${USER} \
      --shell /bin/sh ${USER}