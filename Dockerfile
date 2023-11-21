# ================================
# Build image
# ================================
FROM swift:5.9.1-jammy as build

ARG EXECUTABLE_NAME=Server

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y\
  && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release --static-swift-stdlib

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/${EXECUTABLE_NAME}" ./server

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM ubuntu:jammy

# I found instructions for labeling the image at
# https://blog.scottlowe.org/2017/11/08/how-tag-docker-images-git-commit-information/

ARG REVISION=unspecified
ARG VERSION=0.0
ARG USER_NAME=monotonic
ARG EXECUTABLE_NAME=Server
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.vendor="Llamagraphics, Inc."

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && apt-get -q install -y \
  ca-certificates \
  tzdata \
  # If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
  # libcurl4 \
  # If your app or its dependencies import FoundationXML, also install `libxml2`.
  # libxml2 \
  && rm -r /var/lib/apt/lists/*

# Create a monotonic user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app ${USER_NAME}

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=${USER_NAME}:${USER_NAME} /staging /app

# Ensure all further commands run as the monotonic user
USER ${USER_NAME}:${USER_NAME}

# Let Docker bind to port 8080
EXPOSE 8888

# Start the monotonic service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./server"]
CMD ["--host", "0.0.0.0", "--port", "8888"]