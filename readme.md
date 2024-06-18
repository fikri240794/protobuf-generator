# Protobuf Generator
Generate Protobuf using docker. Generate protobuf for specific language without installing Protocol Buffer Compiler into your system.

Currently only available for golang, and yes, anyone can contribute for other languages.

Build Docker Image:
```console
docker build . --platform linux/amd64 -t protobuf-generator
```

Generate Protobuf:
```console
docker run --rm \
    -v .:/home/src \
    -e PROTOC_VERSION=27.1 \
    -e GO_VERSION=1.18 \
    -e PROTOC_GEN_GO_VERSION=v1.34.0 \
    -e PROTOC_GEN_GO_GRPC_VERSION=v1.3.0 \
    -e PROTO_FILE_PATH=protofilepath \
    -e PROTO_FILE_NAME=protofilename \
    -e PROTO_OUT_PATH=protooutpath \
    protobuf-generator
```


| Environments               | Description                                                                                                                                                      |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PROTOC_VERSION`             | Protocol Buffer Compiler version, default value is latest version.                                                                                             |
| `GO_VERSION`                 | Go Language version, default value is latest version.                                                                                                          |
| `PROTOC_GEN_GO_VERSION`      | google.golang.org/protobuf/cmd/protoc-gen-go version, default value is `latest`. Set this to specific version with compatibility with `GO_VERSION`.            |
| `PROTOC_GEN_GO_GRPC_VERSION` | google.golang.org/grpc/cmd/protoc-gen-go-grpc version, default value is `latest`. Set this to specific version with compatibility with `GO_VERSION`.           |
| `PROTO_FILE_PATH`            | Relative directory path of protobuf files, default value is `.`.                                                                                               |
| `PROTO_FILE_NAME`            | A `protobuf file name.proto` (will generate from single protobuf file), default value is `*.proto` (will generate every proto files inside `PROTO_FILE_PATH`). |
| `PROTO_OUT_PATH`             | Relative directory path when protobuf files is generated, default value is `.`.                                                                                |
