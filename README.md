# docker-wrap-image-with-senzing-apt

## Overview

This repository shows how to
[baked-in](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/baked-in.md)
a Senzing installation into a Debian/Ubuntu based docker image.

## EULA

To use the Senzing code, you must agree to the End User License Agreement (EULA).

1. :warning: This step is intentionally tricky and not simply copy/paste.
   This ensures that you make a conscious effort to accept the EULA.
   Example:

    <code>export SENZING_ACCEPT_EULA="&lt;the value from [this link](https://github.com/Senzing/knowledge-base/blob/master/lists/environment-variables.md#senzing_accept_eula)&gt;"</code>

## Environment variables

1. :pencil2: Identify the existing image to be wrapped.
   Example:

    ```console
    export BASE_IMAGE="senzing/senzing-api-server:2.0.0"
    ```

1. :pencil2: Name the new image that will be produced.
   Example:

    ```console
    export NEW_IMAGE="mycompany/senzing-api-server:2.0.0"
    ```

## Build Docker image

1. Run the `docker build` command.
   Example:

    ```console
    docker build \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        --build-arg SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
        --tag ${NEW_IMAGE} \
        https://github.com/Senzing/docker-wrap-image-with-senzing-apt.git#main
    ```
