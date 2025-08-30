# Protobuf Generator - Base Image with Tools Only
FROM debian:latest

WORKDIR /home

# Install system packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install protoc (latest)
RUN PROTOC_VERSION=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" && \
    unzip "protoc-${PROTOC_VERSION}-linux-x86_64.zip" -d /usr/local/protoc && \
    rm "protoc-${PROTOC_VERSION}-linux-x86_64.zip" && \
    chmod +x /usr/local/protoc/bin/protoc && \
    echo "protoc installed: $(protoc --version)"

# Install gobrew
RUN curl -s -L https://raw.githubusercontent.com/kevincobain2000/gobrew/master/git.io.sh | bash && \
    echo "installed" > /home/.gobrew_version && \
    echo "gobrew installed: $(/root/.gobrew/bin/gobrew version)"

# Set up environment paths
ENV PATH="/home/go/bin:/root/.gobrew/current/bin:/root/.gobrew/bin:/usr/local/protoc/bin:$PATH"
ENV GOPATH="/home/go"

# Copy scripts
COPY scripts/ ./scripts/
RUN find /home/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Create directories
RUN mkdir -p /home/src /home/go

# Set default environment variables
ENV LANG=go
ENV PROTO_FILE_PATH=.
ENV PROTO_FILE_NAME="*.proto"
ENV PROTO_OUT_PATH=.
ENV GO_VERSION=latest
ENV PROTOC_GEN_GO_VERSION=latest
ENV PROTOC_GEN_GO_GRPC_VERSION=latest
ENV DEBUG=0

# Generator script as entry point
CMD ["/home/scripts/generate.sh"]