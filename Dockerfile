ARG BASE_IMAGE=senzing/senzing-base:1.6.10
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2022-08-12

# SENZING_ACCEPT_EULA to be replaced by --build-arg

ARG SENZING_ACCEPT_EULA=no

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
      --output /senzingrepo_1.0.0-1_amd64.deb \
      https://senzing-production-apt.s3.amazonaws.com/senzingrepo_1.0.0-1_amd64.deb \
 && apt -y install \
      /senzingrepo_1.0.0-1_amd64.deb \
 && apt update \
 && rm /senzingrepo_1.0.0-1_amd64.deb

# Install Senzing package.
#   Note: The system location for "data" should be /opt/senzing/data, hence the "mv" command.

RUN apt -y install senzingapi \
 && mv /opt/senzing/data/3.0.0/* /opt/senzing/data/

# Initialize files.

COPY --from=senzing/init-container:latest "/app/init-container.py" "/app/init-container.py"
RUN /app/init-container.py initialize-files

# Finally, make the container a non-root container again.

USER 1001
