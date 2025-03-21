ARG BASE_IMAGE=debian:11.11-slim
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2025-03-21

# SENZING_ACCEPT_EULA to be replaced by --build-arg

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.12.6-25072"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.0-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
    SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
    SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

# Need to be root to do "apt" operations.

USER root

# Install packages via apt-get.

RUN apt-get update \
 && apt-get -y install \
    apt-transport-https \
      curl \
      gnupg \
      wget

# Install Senzing repository index.

RUN curl \
      --output /${SENZING_APT_REPOSITORY_NAME} \
       ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} \
 && apt-get -y install \
      /${SENZING_APT_REPOSITORY_NAME} \
 && apt-get update \
 && rm /${SENZING_APT_REPOSITORY_NAME}

RUN env

RUN apt-get -y install ${SENZING_APT_INSTALL_PACKAGE} 

HEALTHCHECK CMD apt list --installed | grep ${SENZING_APT_INSTALL_PACKAGE}

# Initialize files.

COPY --from=senzing/init-container:latest "/app/init-container.py" "/app/init-container.py"
RUN /app/init-container.py initialize-files

# Finally, make the container a non-root container again.

USER 1001
