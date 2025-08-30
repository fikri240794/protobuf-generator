# 🚀 Protobuf Generator

<div align="center">

**Protocol Buffer Code Generator**

*Generate protobuf code using Docker - zero local dependencies required*

</div>

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [CLI Reference](#cli-reference)
- [Smart Compatibility System](#smart-compatibility-system)
- [Usage Examples](#usage-examples)
- [Architecture](#architecture)
- [Contributing](#contributing)

## Features

- **🐳 Zero Installation**: Everything runs in Docker containers
- **🧠 Smart Version Management**: Auto-compatibility resolution for any language versions (currently only Go)
- **⚡ Persistent Caching**: Faster subsequent runs with named Docker volumes
- **🛠️ CLI Tool**: User-friendly command-line interface
- **🔧 Debug Mode**: Comprehensive logging for troubleshooting
- **📁 Flexible I/O**: Support for separate input/output directories

## Quick Start

### 1. Build the Docker Image

```bash
git clone https://github.com/fikri240794/protobuf-generator.git
cd protobuf-generator
docker build -t protobuf-generator .
```

### 2. Generate Protobuf Files

#### Go Language

```bash
# Basic usage - generates in same directory
./protogen proto/

# Separate input/output directories
./protogen proto/ generated/

# With specific Go version  
./protogen proto/ --go-version 1.21

# With specific protoc version
./protogen proto/ --protoc-version 24.4

# With specific versions for all components
./protogen proto/ --go-version 1.21 --protoc-version 24.4 --protoc-gen-go v1.31.0 --protoc-gen-go-grpc v1.3.0

# Check compatibility before running
./protogen --check-compatibility --go-version 1.21
```

### 3. Example Output

#### Go Language

```
proto/
├── user.proto          # Input
generated/
├── user.pb.go          # Generated protobuf code
└── user_grpc.pb.go     # Generated gRPC code
```

## CLI Reference

### Command Syntax

```bash
./protogen [source_path] [output_path] [OPTIONS]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `source_path` | Directory with .proto files | ✅ |
| `output_path` | Output directory (default: source_path) | ❌ |

### Options

#### Global
| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `-t, --protoc-version` | protoc version | `latest` | `--protoc-version 24.4` |
| `-f, --file` | Proto file pattern | `*.proto` | `--file user.proto` |
| `-d, --debug` | Enable debug logging | `false` | `--debug` |
| `-c, --check-compatibility` | Check version compatibility | - | `--check-compatibility` |
| `-h, --help` | Show help | - | `--help` |

#### Go Language
| Option | Description | Default | Example |
|--------|-------------|---------|---------|
| `-g, --go-version` | Go version | `latest` | `--go-version 1.21` |
| `-p, --protoc-gen-go` | protoc-gen-go version | `latest` | `--protoc-gen-go v1.31.0` |
| `-r, --protoc-gen-go-grpc` | protoc-gen-go-grpc version | `latest` | `--protoc-gen-go-grpc v1.3.0` |

## Smart Compatibility System

### Go Language
The generator automatically resolves compatible versions based on your Go version:

```bash
# Check what versions will be used
./protogen --check-compatibility --go-version 1.21
```

#### Compatibility Matrix

| Go Version | protoc | protoc-gen-go | protoc-gen-go-grpc | Status |
|------------|--------|---------------|-------------------|---------|
| **1.25** (latest) | 28.3 | v1.35.2 | v1.5.1 | ✅ Latest |
| **1.24-1.23** | 25.1 | v1.34.2 | v1.5.1 | ✅ Stable |  
| **1.22-1.21** | 24.4 | v1.31.0 | v1.3.0 | ✅ Stable |
| **1.20-1.19** | 23.4 | v1.28.1 | v1.2.0 | ✅ LTS |
| **1.18-1.17** | 21.12 | v1.27.1 | v1.1.0 | ✅ Legacy |

## Usage Examples

### Basic Generation

```bash
# Generate in same directory
./protogen test/
```

### Debug Mode  

```bash
# See detailed logs
./protogen test/ --debug
```

### Manual Version Override

#### Go Language
```bash
# Advanced: specify exact versions
./protogen test/ \
  --go-version 1.21 \
  --protoc-version 24.4 \
  --protoc-gen-go v1.31.0 \
  --protoc-gen-go-grpc v1.3.0
```

## Architecture

### Project Structure

```
protobuf-generator/
├── protogen                         # CLI entry point
├── Dockerfile                       # Container definition  
├── scripts/
│   ├── generate.sh                  # Main orchestrator
│   ├── core/                        # Core modules
│   │   ├── logger.sh                # Logging system
│   │   ├── env_validator.sh         # Environment validation
│   │   ├── protoc_manager.sh        # Protoc management  
│   │   └── version_compatibility.sh # Smart version resolution
│   ├── generators/                  # Language generators
│   │   └── go_generator.sh          # Go-specific logic
│   └── utils/                       # Utilities
│       └── system_utils.sh          # System functions
└── test/                            # Test files
    └── hello.proto                  # Protobuf files for test generator
```

## Contributing

### Adding Language Support

1. Create generator: `scripts/generators/{{LANG_NAME}}_generator.sh`. Example: `scripts/generators/python_generator.sh`
2. Update compatibility: `scripts/core/version_compatibility.sh`  
3. Update CLI: `protogen`
