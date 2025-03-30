#!/bin/bash
set -e

# Initial configuration
INSTALL_FLAG=false
CREATE_DEB_FLAG=false
TAG="" # If not specified, the script will automatically fetch the latest tag.
# Default configure options - change these if needed.
CONFIG_OPTIONS="--prefix=/usr --enable-fail-if-missing --enable-python3interp=dynamic --enable-terminal --enable-multibyte --enable-fontset --enable-gui=gtk3 --with-python-command=python3"

usage() {
    echo "Usage: $0 [--install] [--tag <tag>] [--config \"configure options\"] [--create-deb]"
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
    --create-deb)
        CREATE_DEB_FLAG=true
        ;;
    *)
        echo "Unknown parameter: $1"
        usage
        ;;
    esac
    shift
done

# Clone the Vim repository
REPO_URL="https://github.com/vim/vim.git"
CLONE_DIR="vim"
if [ ! -d "$CLONE_DIR" ]; then
    echo "Cloning Vim repository..."
    git clone "$REPO_URL"
else
    echo "Vim repository already cloned. Pulling latest changes..."
    cd "$CLONE_DIR"
    git checkout master
    git pull
    cd ..
fi

cd "$CLONE_DIR"

# If no tag is specified, fetch the latest tag from the repository
if [ -z "$TAG" ]; then
    echo "Fetching the latest Vim tag from the repository..."
    TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
    if [ -z "$TAG" ]; then
        echo "Failed to retrieve the latest tag."
        exit 1
    fi
fi
echo "Using tag: $TAG"

# Check out the specified tag
echo "Checking out tag: $TAG"
git checkout "$TAG"

# Run configure with the specified options
echo "Running configure with options: $CONFIG_OPTIONS"
./configure $CONFIG_OPTIONS

# Build the source
echo "Running make..."
make

if [ "$CREATE_DEB_FLAG" = true ]; then
    # Create a Debian package using dpkg-deb
    echo "Creating Debian package with dpkg-deb..."
    PKG_VERSION="${TAG#v}"
    PKG_NAME="vim-custom_${PKG_VERSION}_amd64"
    BUILD_DIR="/tmp/${PKG_NAME}"

    # Prepare the directory structure for the package
    mkdir -p "${BUILD_DIR}/DEBIAN" "${BUILD_DIR}/usr"
    make DESTDIR="${BUILD_DIR}" install

    # Create the control file
    cat <<EOF >"${BUILD_DIR}/DEBIAN/control"
Package: vim-custom
Version: ${PKG_VERSION}
Section: editors
Priority: optional
Architecture: amd64
Maintainer: Your Name <your.email@example.com>
Description: Custom build of Vim
EOF

    # Build the package
    dpkg-deb --build "${BUILD_DIR}" "${PKG_NAME}.deb"

    # If the --install flag was provided, install the generated deb package
    if [ "$INSTALL_FLAG" = true ]; then
        PACKAGE_NAME="${PKG_NAME}.deb"
        if [ -f "$PACKAGE_NAME" ]; then
            echo "Installing Debian package: $PACKAGE_NAME"
            sudo apt install ./"$PACKAGE_NAME"
        else
            echo "Debian package not found: $PACKAGE_NAME"
            exit 1
        fi
    fi
fi

# Clean up
# rm -rf "${BUILD_DIR}"

echo "All steps completed successfully."
