ARG BASE_IMAGE=senzing/senzing-base:1.6.24
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2024-05-22

# SENZING_ACCEPT_EULA to be replaced by --build-arg

ARG SENZING_ACCEPT_EULA=no
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com/senzingrepo_1.0.1-1_all.deb"
ARG SENZING_DATA_VERSION=5.0.0

# Need to be root to do "apt" operations.

USER root

# Install packages via apt.

RUN apt update \
 && apt -y install \
      apt-transport-https \
      curl \
      gnupg \
      sudo \
      wget

# Install Senzing repository index.

RUN curl \
      --output /senzingrepo_1.0.1-1_all.deb \
      ${SENZING_APT_REPOSITORY_URL} \
 && apt -y install \
      /senzingrepo_1.0.1-1_all.deb \
 && apt update \
 && rm /senzingrepo_1.0.1-1_all.deb

# Install Senzing package.
#   Note: The system location for "data" should be /opt/senzing/data, hence the "mv" command.

RUN apt -y install ${SENZING_APT_INSTALL_PACKAGE} \
 && mv /opt/senzing/data/${SENZING_DATA_VERSION}/* /opt/senzing/data/

# Initialize files.

COPY --from=senzing/init-container:latest "/app/init-container.py" "/app/init-container.py"
RUN /app/init-container.py initialize-files

# Finally, make the container a non-root container again.

USER 1001
