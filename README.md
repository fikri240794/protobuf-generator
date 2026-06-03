<div align="center">
  <h1>⚡ Universal Protobuf Generator</h1>
  <p>Generate Protocol Buffers across multiple programming languages via Docker—blazing fast, without installing anything on your host machine!</p>
</div>

---

## 🌟 Why this Generator?

- **Zero Host Dependencies:** You only need Docker. No need to pollute your system with `protoc`, Go, Python, or plugins.
- **Ultra Fast (Smart Caching):** Uses a Docker Named Volume to persist downloaded compilers and language managers. The first run takes seconds, the subsequent runs take milliseconds.
- **Multi-Architecture Support:** Automatically detects your CPU architecture (AMD64 / Apple Silicon ARM64) and downloads the correct binaries.
- **Language Agnostic (Extensible):** Built with a modular architecture. Currently supports Go, with Python and others coming soon! You can easily contribute your own language generator.
- **Root-Safe:** Automatically fixes file ownership so generated files aren't locked to the `root` user on your host.

---

## 🛠️ Supported Languages

- [x] **Go** (via [gobrew](https://github.com/kevincobain2000/gobrew) for instant version switching)
- [ ] *Python (Coming Soon)*
- [ ] *Java (Coming Soon)*
- [ ] *(Want your favorite language? Read the Contributing section!)*

---

## 🚀 Quick Start

### 1. Build the Docker Image
```bash
docker build -t protobuf-generator .
```

### 2. Generate Protobuf Files
Run this command from the root of any of your projects.

**Example for Go:**
```bash
docker run --rm \
    -v protobuf-generator:/root \
    -v .:/home/src \
    -e TARGET_LANG=go \
    -e PROTO_FILE_PATH=protofilepath \
    -e PROTO_OUT_PATH=protooutpath \
    protobuf-generator
```

> [!TIP]
> **What is `-v protobuf-generator:/root`?**
> This creates a persistent "Docker Volume" named `protobuf-generator`. It safely stores the downloaded `protoc` and language binaries so they are never re-downloaded, making your generations extremely fast!

---

## ⚙️ Configuration Variables

| Variable          | Description                                                                           | Default    |
| ----------------- | ------------------------------------------------------------------------------------- | ---------- |
| `TARGET_LANG`     | **(Required)** The programming language you want to generate code for (e.g., `go`).   | `go`       |
| `PROTOC_VERSION`  | Version of the Google Protocol Buffer Compiler. If empty, fetches the latest release. | *(Latest)* |
| `PROTO_FILE_PATH` | Relative directory path containing your `.proto` files inside the mounted project.    | `.`        |
| `PROTO_FILE_NAME` | Pattern to match protobuf files.                                                      | `*.proto`  |
| `PROTO_OUT_PATH`  | Relative directory path where the generated files should be placed.                   | `.`        |

### 🟢 Go-Specific Variables
| Variable                     | Description                                                                                           | Default  |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- | -------- |
| `GO_VERSION`                 | Version of Go to use (managed by [gobrew](https://github.com/kevincobain2000/gobrew)). e.g., `1.23.0` | `latest` |
| `PROTOC_GEN_GO_VERSION`      | Version for the `protoc-gen-go` plugin.                                                               | `latest` |
| `PROTOC_GEN_GO_GRPC_VERSION` | Version for the `protoc-gen-go-grpc` plugin.                                                          | `latest` |

---

## 🤝 How to Contribute (Add a New Language)

We built this generator to be completely modular (DRY principle). Adding a new language is incredibly simple!

1. Create a new file in the `scripts/generators/` folder, for example: `scripts/generators/python.sh`
2. Inside that file, define a single function named `generate_python()`:
   ```bash
   #!/bin/bash
   
   generate_python() {
       echo "Installing Python dependencies..."
       # Your logic to install python plugins and run protoc
       
       # Example protoc call:
       # protoc --proto_path="$PROTO_FILE_PATH" --python_out="$PROTO_OUT_PATH" ...
   }
   ```
3. Submit a Pull Request! The `scripts/entrypoint.sh` will automatically detect your new language when a user sets `TARGET_LANG=python`.

---
*Happy Generating!* 🚀
