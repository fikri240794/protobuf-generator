FROM debian:latest

WORKDIR /home
COPY . .

# GENERATOR
ENV LANG="go"
ENV GENERATOR="/home/$LANG-pb-generator.sh"

# PROTOBUF FILE
ENV PROTO_FILE_PATH="."
ENV PROTO_FILE_NAME="*.proto"
ENV PROTO_OUT_PATH="."

# GO
ENV PROTOC_VERSION=""
ENV GO_VERSION=""
ENV PROTOC_GEN_GO_VERSION="latest"
ENV PROTOC_GEN_GO_GRPC_VERSION="latest"

RUN chmod +x *.sh
RUN mkdir /home/src

CMD $GENERATOR