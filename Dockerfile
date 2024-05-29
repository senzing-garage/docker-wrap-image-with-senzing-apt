ARG BASE_IMAGE=senzing/senzing-base:1.6.24
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2024-05-22

# SENZING_ACCEPT_EULA to be replaced by --build-arg

ARG SENZING_ACCEPT_EULA=no
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com/senzingrepo_2.0.0-1_all.deb"
ARG SENZING_DATA_VERSION=5.0.0

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
  --output /senzingrepo_2.0.0-1_all.deb \
  ${SENZING_APT_REPOSITORY_URL} \
  && apt-get -y install \
  /senzingrepo_2.0.0-1_all.deb \
  && apt-get update \
  && rm /senzingrepo_2.0.0-1_all.deb

# Install Senzing package.
#   Note: The system location for "data" should be /opt/senzing/data, hence the "mv" command.

RUN apt-get -y install ${SENZING_APT_INSTALL_PACKAGE} \
  && mv /opt/senzing/data/${SENZING_DATA_VERSION}/* /opt/senzing/data/

HEALTHCHECK CMD apt list --installed | grep ${SENZING_APT_INSTALL_PACKAGE}

# Initialize files.

COPY --from=senzing/init-container:latest "/app/init-container.py" "/app/init-container.py"
RUN /app/init-container.py initialize-files

# Finally, make the container a non-root container again.

USER 1001
