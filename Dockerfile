FROM debian:latest

# Install build-time dependencies
RUN apt-get update -y && apt-get install -y curl unzip git jq

# Install gobrew
RUN curl -sL https://raw.githubusercontent.com/kevincobain2000/gobrew/master/git.io.sh | bash

# Add gobrew and protoc to PATH
ENV PATH="/root/.gobrew/current/bin:/root/.gobrew/bin:/root/protoc/bin:$PATH"

# Setup workspace
WORKDIR /home
RUN mkdir -p /home/src /opt/pb-gen

# Copy scripts
COPY scripts/ /opt/pb-gen/
RUN chmod +x /opt/pb-gen/*.sh /opt/pb-gen/generators/*.sh

# ENVIRONMENT VARIABLES
# User must define TARGET_LANG (e.g., go, python)
ENV TARGET_LANG="go"

# PROTOBUF FILE CONFIG
ENV PROTO_FILE_PATH="."
ENV PROTO_FILE_NAME="*.proto"
ENV PROTO_OUT_PATH="."

# OPTIONAL TOOL VERSIONS
ENV PROTOC_VERSION=""

# Set entrypoint
CMD ["/opt/pb-gen/entrypoint.sh"]