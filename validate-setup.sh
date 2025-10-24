#!/bin/bash

echo "🚀 JPEG to PDF Converter - Setup Validation"
echo "============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Check if required files exist
required_files=(
    "docker-compose.yml"
    "backend/Dockerfile"
    "backend/package.json"
    "backend/app.js"
    "frontend/Dockerfile"
    "frontend/package.json"
    "frontend/vite.config.js"
    "frontend/nginx.conf"
    "frontend/src/App.jsx"
    "frontend/src/main.jsx"
    "frontend/index.html"
)

echo "🔍 Checking required files..."
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        exit 1
    fi
done

echo ""
echo "🏗️  Building Docker images..."
docker-compose build

if [ $? -eq 0 ]; then
    echo "✅ Docker images built successfully"
else
    echo "❌ Docker build failed"
    exit 1
fi

echo ""
echo "🧪 Testing Docker Compose configuration..."
docker-compose config > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration is invalid"
    exit 1
fi

echo ""
echo "🎉 Setup validation completed successfully!"
echo ""
echo "To start the application, run:"
echo "  docker-compose up --build"
echo ""
echo "To start in detached mode:"
echo "  docker-compose up --build -d"
echo ""
echo "To stop the application:"
echo "  docker-compose down"
