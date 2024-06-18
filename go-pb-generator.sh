#!/bin/bash

cd /home

apt-get update -y && apt-get install curl unzip -y

# INSTALL PROTOC
if [[ -z "$PROTOC_VERSION" ]]; then
    export PROTOC_VERSION=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | grep -i "tag_name" | awk -F '"' '{print $4}' | sed 's/v//')
fi
curl -o /home/protoc.zip -LO https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip
mkdir /usr/local/protoc && unzip /home/protoc.zip -d /usr/local/protoc && rm /home/protoc.zip
export PATH="$PATH:/usr/local/protoc/bin"

# INSTALL GO
if [[ -z "$GO_VERSION" ]]; then
    export GO_VERSION=$(curl -s -L https://golang.org/VERSION?m=text | grep -i "go")
else
    export GO_VERSION="go$GO_VERSION"
fi
curl -o /home/go.tar.gz -LO https://go.dev/dl/$GO_VERSION.linux-amd64.tar.gz
tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz && mkdir /home/go
export GOPATH="/home/go"
export GOROOT="/usr/local/go"
export PATH="$PATH:$GOROOT/bin"
export PATH="$PATH:$GOPATH/bin"
go install google.golang.org/protobuf/cmd/protoc-gen-go@$PROTOC_GEN_GO_VERSION && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$PROTOC_GEN_GO_GRPC_VERSION

# GENERATE PROTOBUF
cd /home/src
find . -name "$PROTO_FILE_NAME" -exec protoc --proto_path=$PROTO_FILE_PATH --go_out=$PROTO_OUT_PATH --go_opt=paths=source_relative --go-grpc_out=$PROTO_OUT_PATH --go-grpc_opt=paths=source_relative {} \;
