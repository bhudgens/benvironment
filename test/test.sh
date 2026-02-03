#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER_NAME="benvironment-test"
IMAGE_NAME="benvironment-test:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start    - Start/attach to test container (default)"
    echo "  rebuild  - Remove container and rebuild image from scratch"
    echo "  remove   - Remove the test container (keeps image)"
    echo "  refresh  - Clear cached files so next source picks up latest"
    echo "  clean    - Remove both container and image"
    echo "  status   - Show container status"
    echo "  logs     - Show container logs"
    echo ""
    echo "If no command is given, defaults to 'start'"
}

status() {
    echo -e "${YELLOW}Container Status:${NC}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    else
        echo "  Container does not exist"
    fi
    echo ""
    echo -e "${YELLOW}Image Status:${NC}"
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        docker images --filter "reference=${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    else
        echo "  Image does not exist"
    fi
}

build_image() {
    echo -e "${GREEN}Building test image...${NC}"
    docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"
}

ensure_image() {
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        build_image
    fi
}

remove_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${YELLOW}Removing container ${CONTAINER_NAME}...${NC}"
        docker rm -f "$CONTAINER_NAME"
    fi
}

remove_image() {
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        echo -e "${YELLOW}Removing image ${IMAGE_NAME}...${NC}"
        docker rmi "$IMAGE_NAME"
    fi
}

start() {
    ensure_image

    # Check if container exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        # Container exists - check if running
        if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            echo -e "${GREEN}Attaching to running container...${NC}"
            docker exec -it "$CONTAINER_NAME" /bin/bash
        else
            echo -e "${GREEN}Starting stopped container...${NC}"
            docker start -ai "$CONTAINER_NAME"
        fi
    else
        # Container doesn't exist - create it
        echo -e "${GREEN}Creating new test container...${NC}"
        echo -e "${YELLOW}Mounting ${PROJECT_DIR} to /home/testuser/benvironment${NC}"
        docker run -it \
            --name "$CONTAINER_NAME" \
            -v "${PROJECT_DIR}:/home/testuser/benvironment:ro" \
            "$IMAGE_NAME" \
            /bin/bash -c '
                echo "=================================================="
                echo "Benvironment Test Container"
                echo "=================================================="
                echo ""
                echo "Running install.sh (simulates: bash -s <<< curl http://b.environ.men/)"
                echo ""
                cd ~/benvironment && bash ./install.sh
                echo ""
                echo "=================================================="
                echo "Install complete. Run: zsh -l"
                echo "=================================================="
                exec /bin/bash
            '
    fi
}

rebuild() {
    echo -e "${RED}Rebuilding from scratch...${NC}"
    remove_container
    remove_image
    build_image
    start
}

refresh() {
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}Container does not exist. Run 'start' first.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Clearing cached files in container...${NC}"
    docker start "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker exec "$CONTAINER_NAME" bash -c 'rm -rf ~/run ~/.*zshrc ~/.oh-my-zsh ~/.benvironment'
    echo -e "${GREEN}Cache cleared. Starting container...${NC}"
    start
}

logs() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker logs "$CONTAINER_NAME"
    else
        echo "Container does not exist"
    fi
}

# Main
case "${1:-start}" in
    start)
        start
        ;;
    rebuild)
        rebuild
        ;;
    remove)
        remove_container
        ;;
    clean)
        remove_container
        remove_image
        echo -e "${GREEN}Cleaned up.${NC}"
        ;;
    refresh)
        refresh
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        usage
        exit 1
        ;;
esac
