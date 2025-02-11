<<<<<<< HEAD

FROM debian:bullseye-slim

# The version of Gophish to install
ARG GOPHISH_VERSION="0.11.0-cisa.1"

# The directory where the get-api-key script will be installed
ENV SCRIPT_DIR="/usr/local/bin"
=======
# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
FROM docker.io/library/python:3.13.2-alpine3.21 AS compile-stage

###
# Unprivileged user variables
###
ARG CISA_USER="cisa"
ENV CISA_HOME="/home/${CISA_USER}"
ENV VIRTUAL_ENV="${CISA_HOME}/.venv"

# Versions of the Python packages installed directly
ENV PYTHON_PIP_VERSION=25.0.1
ENV PYTHON_PIPENV_VERSION=2024.4.1
ENV PYTHON_SETUPTOOLS_VERSION=75.8.0
ENV PYTHON_WHEEL_VERSION=0.45.1

###
# Install the specified versions of pip, setuptools, and wheel into the system
# Python environment; install the specified version of pipenv into the system Python
# environment; set up a Python virtual environment (venv); and install the specified
# versions of pip, setuptools, and wheel into the venv.
#
# Note that we use the --no-cache-dir flag to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN python3 -m pip install --no-cache-dir --upgrade \
        pip==${PYTHON_PIP_VERSION} \
        setuptools==${PYTHON_SETUPTOOLS_VERSION} \
        wheel==${PYTHON_WHEEL_VERSION} \
    && python3 -m pip install --no-cache-dir --upgrade \
        pipenv==${PYTHON_PIPENV_VERSION} \
    # Manually create the virtual environment
    && python3 -m venv ${VIRTUAL_ENV} \
    # Ensure the core Python packages are installed in the virtual environment
    && ${VIRTUAL_ENV}/bin/python3 -m pip install --no-cache-dir --upgrade \
        pip==${PYTHON_PIP_VERSION} \
        setuptools==${PYTHON_SETUPTOOLS_VERSION} \
        wheel==${PYTHON_WHEEL_VERSION}

###
# Check the Pipfile configuration and then install the Python dependencies into
# the virtual environment.
#
# Note that pipenv will install into a virtual environment if the VIRTUAL_ENV
# environment variable is set.
###
WORKDIR /tmp
COPY src/Pipfile src/Pipfile.lock ./
RUN pipenv check --verbose \
    && pipenv install --clear --deploy --extra-pip-args "--no-cache-dir" --verbose

# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
<<<<<<< HEAD
FROM docker.io/library/python:3.13.1-alpine3.20 AS build-stage
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561
=======
FROM docker.io/library/python:3.13.2-alpine3.21 AS build-stage
>>>>>>> e8ec18bb4cfbcdc26f704c489e98112d312d9bdb

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
LABEL org.opencontainers.image.authors="vm-fusion-dev-group@trio.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ARG CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"
<<<<<<< HEAD

###
# Upgrade the system
###
RUN apt-get update --quiet --quiet \
    && apt-get upgrade --quiet --quiet
=======
ENV VIRTUAL_ENV="${CISA_HOME}/.venv"
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561

###
# Create unprivileged user
###
RUN groupadd --system --gid ${CISA_GID} ${CISA_GROUP} \
    && useradd --system --uid ${CISA_UID} --gid ${CISA_GROUP} --comment "${CISA_USER} user" ${CISA_USER}

###
<<<<<<< HEAD
# Install everything we need
#
# Install dependencies are only needed for software installation and
# will be removed at the end of the build process.
###
ENV DEPS \
    ca-certificates \
    libsqlite3-dev \
    sqlite3
ENV INSTALL_DEPS \
    unzip \
    wget
RUN apt-get install --quiet --quiet --yes \
    --no-install-recommends --no-install-suggests \
    $DEPS $INSTALL_DEPS

COPY bin/get-api-key ${SCRIPT_DIR}

# TODO: Revert from cisagov/gophish back to gophish/gophish after all of our
# pull requests have been merged; including, but potentially not limited to:
# - https://github.com/gophish/gophish/pull/1484
# - https://github.com/gophish/gophish/pull/1486
# See https://github.com/cisagov/gophish-docker/issues/25 for details.
RUN wget --no-verbose https://github.com/cisagov/gophish/releases/download/v${GOPHISH_VERSION}/gophish-v${GOPHISH_VERSION}-linux-64bit.zip \
    && unzip -d ${CISA_HOME} gophish-v${GOPHISH_VERSION}-linux-64bit.zip \
    && rm --force gophish-v${GOPHISH_VERSION}-linux-64bit.zip
RUN chmod +x ${CISA_HOME}/gophish \
    && ln --symbolic --no-dereference --force /run/secrets/config.json ${CISA_HOME}/config.json \
    && mkdir --parents ${CISA_HOME}/data \
    && ln --symbolic --no-dereference --force ${CISA_HOME}/data/gophish.db ${CISA_HOME}/gophish.db

###
# Remove install dependencies
###
RUN apt-get remove --quiet --quiet $INSTALL_DEPS

###
# Clean up aptitude cruft
###
RUN apt-get --quiet --quiet clean \
    && rm --recursive --force /var/lib/apt/lists/*

###
# Setup working directory and entrypoint
###
RUN chown --recursive ${CISA_USER}:${CISA_GROUP} ${CISA_HOME}
=======
# Copy in the Python virtual environment created in compile-stage, symlink the
# Python binary in the venv to the system-wide Python, and add the venv to the PATH.
#
# Note that we symlink the Python binary in the venv to the system-wide Python so that
# any calls to `python3` will use our virtual environment. We are using short flags
# because the ln binary in Alpine Linux does not support long flags. The -f instructs
# ln to remove the existing file and the -s instructs ln to create a symbolic link.
###
COPY --from=compile-stage --chown=${CISA_USER}:${CISA_GROUP} ${VIRTUAL_ENV} ${VIRTUAL_ENV}
RUN ln -fs "$(command -v python3)" "${VIRTUAL_ENV}"/bin/python3
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561

###
# Prepare to run
###
<<<<<<< HEAD
USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}
EXPOSE 3333/TCP 8080/TCP
ENTRYPOINT ["./gophish"]
=======
ENV ECHO_MESSAGE="Hello World from Dockerfile"
WORKDIR ${CISA_HOME}
USER ${CISA_USER}:${CISA_GROUP}
EXPOSE 8080/TCP
VOLUME ["/var/log"]
ENTRYPOINT ["example"]
CMD ["--log-level", "DEBUG", "8", "2"]
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561
