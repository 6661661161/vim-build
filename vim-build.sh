#!/bin/bash
set -e

# Initial configuration
INSTALL_FLAG=false
TAG=""   # If not specified, the script will automatically fetch the latest tag.
# Default configure options - change these if needed.
CONFIG_OPTIONS="--prefix=/usr --with-features=huge --enable-multibyte --enable-python3interp=yes --with-python3-config-dir=$(python3-config --configdir)"

usage() {
    echo "Usage: $0 [--install] [--tag <tag>] [--config \"configure options\"]"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --install)
      INSTALL_FLAG=true
      ;;
    --tag)
      if [ -z "$2" ]; then usage; fi
      TAG="$2"
      shift
      ;;
    --config)
      if [ -z "$2" ]; then usage; fi
      CONFIG_OPTIONS="$2"
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      usage
      ;;
  esac
  shift
done

# If no tag is specified, fetch the latest tag from GitHub using the GitHub API (jq is required)
if [ -z "$TAG" ]; then
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required. Please install it (e.g., sudo apt install jq)."
    exit 1
  fi
  echo "Fetching the latest Vim tag from GitHub API..."
  TAG=$(curl -s https://api.github.com/repos/vim/vim/tags | jq -r '.[0].name')
  if [ -z "$TAG" ]; then
    echo "Failed to retrieve the latest tag."
    exit 1
  fi
fi
echo "Using tag: $TAG"

# Download the source tarball
TARBALL_URL="https://github.com/vim/vim/archive/refs/tags/${TAG}.tar.gz"
echo "Downloading source from: $TARBALL_URL"
curl -L -o vim.tar.gz "$TARBALL_URL"

# Extract the tarball
echo "Extracting tarball..."
tar -xzvf vim.tar.gz

# Determine the extracted directory (using the first entry in the tarball)
EXTRACTED_DIR=$(tar -tzf vim.tar.gz | head -1 | cut -f1 -d"/")
echo "Changing to directory: $EXTRACTED_DIR"
cd "$EXTRACTED_DIR"

# Run configure with the specified options
echo "Running configure with options: $CONFIG_OPTIONS"
./configure $CONFIG_OPTIONS

# Build the source
echo "Running make..."
make

# Create a Debian package using checkinstall
echo "Creating Debian package with checkinstall..."
if ! command -v checkinstall >/dev/null 2>&1; then
  echo "checkinstall is not installed. Installing it now..."
  sudo apt-get update
  sudo apt-get install -y checkinstall
fi

# Remove the 'v' prefix if present for the package version
PKG_VERSION="${TAG#v}"
sudo checkinstall --pkgname=vim-custom --pkgversion=${PKG_VERSION} --backup=no --deldoc=yes --fstrans=no --default

# If the --install flag was provided, install the generated deb package
if [ "$INSTALL_FLAG" = true ]; then
  PACKAGE_NAME="vim-custom_${PKG_VERSION}_amd64.deb"
  if [ -f "$PACKAGE_NAME" ]; then
    echo "Installing Debian package: $PACKAGE_NAME"
    sudo apt install ./"$PACKAGE_NAME"
  else
    echo "Debian package not found: $PACKAGE_NAME"
    exit 1
  fi
fi

echo "All steps completed successfully."
