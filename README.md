# vim-build.sh - Vim Custom Build Script

This repository contains a shell script (`vim-build.sh`) that automates the process of downloading, building, packaging, and optionally installing Vim from its GitHub source.

## Features

- **Automatic Tag Retrieval:** If no tag is provided, the script fetches the latest Vim tag from GitHub.
- **Custom Build:** Configures and builds Vim with user-defined `./configure` options.
- **Optional Deb Package Creation:** Creates a Debian package if the `--create-deb` option is specified.
- **Optional Installation:** If the `--install` option is specified, the generated Debian package is automatically installed via `sudo apt install`.

## Requirements

- `git`
- `make`
- `dpkg-deb`
- `sudo` privileges (for installation)

## Usage

```bash
./vim-build.sh [--install] [--tag <tag>] [--config "<configure options>"] [--create-deb]
```

### Options

- `--install`: Installs the generated Debian package (requires `--create-deb` to be specified).
- `--tag <tag>`: Specifies the Vim version tag to build. If omitted, the latest tag is used.
- `--config "<configure options>"`: Custom `./configure` options for building Vim.
- `--create-deb`: Creates a Debian package for the built Vim.

### Example

```bash
# Build Vim with default options, create a Debian package, and install it
./vim-build.sh --create-deb --install
```
