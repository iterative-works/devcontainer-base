#!/bin/bash
set -e

IMAGE_NAME="iterative-works/devcontainer-base"
TAG="${TAG:-latest}"

# Parse command line arguments
PUSH=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$HELP" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build the iterative-works/devcontainer-base Docker image"
    echo ""
    echo "Options:"
    echo "  --push          Push the image to registry after building"
    echo "  --tag TAG       Tag for the image (default: latest)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build image locally"
    echo "  $0 --push            # Build and push image"
    echo "  $0 --tag v1.0 --push # Build and push with specific tag"
    exit 0
fi

echo "🔨 Building Docker image: ${IMAGE_NAME}:${TAG}"

# Build the image
docker build -t "${IMAGE_NAME}:${TAG}" .

echo "✅ Successfully built ${IMAGE_NAME}:${TAG}"

if [ "$PUSH" = true ]; then
    echo "📤 Pushing ${IMAGE_NAME}:${TAG} to registry..."
    docker push "${IMAGE_NAME}:${TAG}"
    echo "✅ Successfully pushed ${IMAGE_NAME}:${TAG}"
else
    echo "💡 To push this image, run:"
    echo "   $0 --push"
    echo "   or: docker push ${IMAGE_NAME}:${TAG}"
fi

echo ""
echo "🐳 Image is ready to use:"
echo "   docker run -it ${IMAGE_NAME}:${TAG}"