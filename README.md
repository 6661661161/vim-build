# vim-build.sh - Vim Custom Build Script

This repository contains a shell script (`vim-build.sh`) that automates the process of downloading, building, packaging, and optionally installing Vim from its GitHub source.

## Features

- **Automatic Tag Retrieval:** If no tag is provided, the script fetches the latest Vim tag from GitHub using the GitHub API.
- **Source Download & Extraction:** Downloads the tarball for the specified tag and extracts it.
- **Custom Build:** Configures and builds Vim with user-defined `./configure` options.
- **Deb Package Creation:** Uses [checkinstall](https://help.ubuntu.com/community/CheckInstall) to create a Debian package.
- **Optional Installation:** If the `--install` option is specified, the generated Debian package is automatically installed via `sudo apt install`.

## Requirements

- `curl`
- `tar`
- `make`
- `jq` (for retrieving the latest tag from GitHub)
- `checkinstall` (the script will attempt to install it if missing)
- `sudo` privileges

## Usage

```bash
./vim-build.sh [--install] [--tag <tag>] [--config "<configure options>"]
