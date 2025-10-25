# 🖼️ JPEG to PDF Converter

A modern, Docker-based web application that converts multiple JPEG images into a single PDF document. Built with React frontend and Node.js backend using a clean **2-tier architecture** (no database required).

c
## ✨ Features

- **Drag & Drop Interface**: Intuitive file upload with visual previews
- **Multiple Compression Levels**: Choose between Normal, Compressed, or Ultra Compressed
- **Batch Processing**: Convert up to 20 images at once
- **Custom Filenames**: Name your PDF files as you want
- **Dark Mode**: Toggle between light and dark themes
- **Responsive Design**: Works perfectly on desktop and mobile
- **Docker Ready**: Easy deployment with Docker Compose
- **Pure 2-Tier Architecture**: No database complexity

## 🏗️ Architecture

```
Frontend (React + Vite) → Backend (Node.js + Express) → PDF Output
```

**No Database Layer** - Perfect for stateless file conversion!

## 🚀 Quick Start

### Prerequisites

- **Docker** and **Docker Compose** installed
- **Git** (for version control)
- **Node.js 18+** (for local development)

### 1. Clone and Run

```bash
# Clone the repository
git clone <your-repo-url>
cd jpeg-to-pdf-docker-compose

# Start the application
docker-compose up --build -d
```

### 2. Access the Application

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **API Documentation**: http://localhost:3000/

## 🧪 **Step-by-Step Testing Guide (Learn Each Command)**

### **Step 1: Check if Docker is Running**

First, let's see if Docker is working:

```bash
# Check Docker version
docker --version

# Check Docker Compose version  
docker-compose --version
```

**What this does**: Verifies Docker is installed and working.

---

### **Step 2: Start Your Application**

```bash
# Navigate to your project folder
cd jpeg-to-pdf-docker-compose

# Start the application
docker-compose up -d
```

**What this does**: 
- `-d` means "detached mode" (runs in background)
- Downloads images, builds containers, starts services

---

### **Step 3: Check if Containers are Running**

```bash
# See all running containers
docker ps
```

**What you should see**:
```
NAMES                  STATUS                     PORTS
jpeg-to-pdf-frontend   Up X minutes              0.0.0.0:5173->80/tcp
jpeg-to-pdf-backend    Up X minutes (healthy)    0.0.0.0:3000->3000/tcp
```

**What this tells you**:
- ✅ Both containers are running
- ✅ Ports are mapped correctly
- ✅ Backend shows "healthy" status

---

### **Step 4: Test Backend API (Learn HTTP Testing)**

#### **4a. Test Health Endpoint**

```bash
# Test if backend is responding
curl http://localhost:3000/health
```

**What you should see**:
```json
{
  "status": "ok",
  "timestamp": "2025-10-25T04:24:03.405Z",
  "uptime": 545.015926916,
  "architecture": "2-tier"
}
```

**What this means**:
- ✅ Backend is running
- ✅ API is responding
- ✅ Shows uptime and architecture

#### **4b. Test API Documentation**

```bash
# Get API information
curl http://localhost:3000/
```

**What you should see**:
```json
{
  "message": "JPEG to PDF Converter API",
  "version": "1.0.0",
  "architecture": "2-tier",
  "endpoints": {
    "POST /convert": "Convert images to PDF",
    "GET /health": "Health check"
  }
}
```

**What this means**:
- ✅ API documentation is working
- ✅ Shows available endpoints
- ✅ Confirms 2-tier architecture

#### **4c. Test File Validation**

```bash
# Test with invalid file (should fail)
curl -X POST -F "images=@/dev/null" http://localhost:3000/convert
```

**What you should see**:
```json
{"error":"Only image files are allowed"}
```

**What this means**:
- ✅ File validation is working
- ✅ API rejects invalid files
- ✅ Error handling is working

---

### **Step 5: Test Frontend (Browser Testing)**

#### **5a. Open Frontend in Browser**

1. **Open your web browser**
2. **Go to**: `http://localhost:5173`
3. **You should see**: Pixelforge interface with drag & drop area

#### **5b. Test Drag & Drop**

1. **Find some JPEG images** on your computer
2. **Drag them** onto the drop zone
3. **You should see**: Image previews appear

#### **5c. Test Conversion**

1. **Click "Convert" button**
2. **You should see**: "Converting..." text
3. **Wait for download**: PDF should download automatically

#### **5d. Test Different Features**

- **Compression Levels**: Try Normal, Compressed, Ultra Compressed
- **Custom Filename**: Change filename before converting
- **Dark Mode**: Toggle the switch
- **Multiple Images**: Upload 2-5 images together

---

### **Step 6: Check Logs (Learn Debugging)**

```bash
# See backend logs
docker logs jpeg-to-pdf-backend

# See frontend logs  
docker logs jpeg-to-pdf-frontend

# See all logs together
docker-compose logs
```

**What this shows**:
- ✅ Application startup messages
- ✅ Any errors or warnings
- ✅ Request logs

---

### **Step 7: Stop Application (Learn Cleanup)**

```bash
# Stop all services
docker-compose down

# Verify containers stopped
docker ps
```

**What this does**:
- Stops all containers
- Removes networks
- Cleans up resources

## 📁 Project Structure

```
jpeg-to-pdf-docker-compose/
├── backend/
│   ├── app.js              # Main backend application
│   ├── package.json        # Backend dependencies
│   └── Dockerfile         # Backend container config
├── frontend/
│   ├── src/
│   │   ├── App.jsx        # Main React component
│   │   ├── App.css        # Styling
│   │   └── main.jsx       # React entry point
│   ├── index.html         # HTML template
│   ├── package.json       # Frontend dependencies
│   ├── vite.config.js     # Vite configuration
│   ├── nginx.conf         # Nginx configuration
│   └── Dockerfile         # Frontend container config
├── docker-compose.yml     # Docker services configuration
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## 🔧 Development

### Local Development (without Docker)

```bash
# Backend
cd backend
npm install
npm run dev

# Frontend (in another terminal)
cd frontend
npm install
npm run dev
```

### Docker Development

```bash
# Rebuild and restart
docker-compose down
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📤 **Step-by-Step GitHub Upload Guide (Learn Git Commands)**

### **Step 1: Initialize Git Repository (Learn Git Basics)**

```bash
# Navigate to your project directory
cd jpeg-to-pdf-docker-compose

# Initialize git repository (creates .git folder)
git init
```

**What this does**: Creates a new Git repository in your project folder.

```bash
# Check git status (see what files are untracked)
git status
```

**What you should see**: List of files that are not tracked by Git yet.

```bash
# Add all files to staging area
git add .
```

**What this does**: Stages all files for the first commit.

```bash
# Create your first commit
git commit -m "Initial commit: JPEG to PDF Converter with 2-tier architecture"
```

**What this does**: Creates a snapshot of your project with a descriptive message.

---

### **Step 2: Create GitHub Repository (Learn GitHub Interface)**

#### **2a. Go to GitHub Website**

1. **Open your browser** and go to: `https://github.com`
2. **Sign in** to your GitHub account
3. **Click the "+" button** in the top right corner
4. **Select "New repository"**

#### **2b. Fill Repository Details**

1. **Repository name**: `jpeg-to-pdf-converter` (or your preferred name)
2. **Description**: `Modern JPEG to PDF converter with React frontend and Node.js backend`
3. **Visibility**: Choose **Public** (so others can see it) or **Private**
4. **Important**: **DON'T** check any boxes for:
   - ❌ Add a README file
   - ❌ Add .gitignore  
   - ❌ Choose a license
5. **Click "Create repository"**

**Why we don't check those boxes**: We already have these files in our project!

---

### **Step 3: Connect Local Repository to GitHub (Learn Remote)**

After creating the repository, GitHub will show you commands. Use these:

```bash
# Add GitHub as remote origin (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
```

**What this does**: Connects your local repository to GitHub.

```bash
# Verify remote was added
git remote -v
```

**What you should see**: Your GitHub repository URL listed.

```bash
# Push your code to GitHub
git push -u origin main
```

**What this does**: 
- `push`: Uploads your local commits to GitHub
- `-u origin main`: Sets up tracking between local and remote
- `origin`: The name of your remote repository
- `main`: The branch name

---

### **Step 4: Verify Upload (Learn GitHub Interface)**

#### **4a. Check Your Repository**

1. **Refresh your GitHub repository page**
2. **You should see**: All your project files
3. **Check the README**: It should display with proper formatting

#### **4b. Test Repository Features**

1. **Click on files** to see their content
2. **Check the README.md** - it should show nicely formatted
3. **Look at the file structure** - should match your local project

---

### **Step 5: Learn Git Commands (For Future Updates)**

#### **5a. Making Changes**

```bash
# After making changes to files, check status
git status

# Add specific files
git add filename.js

# Or add all changes
git add .

# Commit changes
git commit -m "Description of what you changed"

# Push to GitHub
git push
```

#### **5b. Useful Git Commands**

```bash
# See commit history
git log

# See what files changed
git diff

# See current branch
git branch

# Create new branch
git checkout -b new-feature

# Switch back to main
git checkout main
```

---

### **Step 6: Understanding What You Just Did**

**Git Concepts You Learned**:

1. **Repository**: A folder tracked by Git
2. **Commit**: A snapshot of your project at a point in time
3. **Remote**: A copy of your repository on GitHub
4. **Push**: Upload local changes to remote repository
5. **Pull**: Download changes from remote repository

**GitHub Concepts You Learned**:

1. **Repository**: Your project's home on GitHub
2. **README**: Documentation that shows on your repository page
3. **Public/Private**: Who can see your code
4. **Remote URL**: The address of your GitHub repository

## 🐛 Troubleshooting

### Common Issues

#### 1. "Cannot GET /" Error

**Problem**: Backend not responding
**Solution**:
```bash
# Check if backend is running
docker ps | grep backend

# Check backend logs
docker logs jpeg-to-pdf-backend

# Restart if needed
docker-compose restart backend
```

#### 2. Frontend Not Loading

**Problem**: Frontend shows error or blank page
**Solution**:
```bash
# Check frontend logs
docker logs jpeg-to-pdf-frontend

# Check if frontend is accessible
curl -I http://localhost:5173

# Rebuild frontend
docker-compose up --build frontend -d
```

#### 3. Port Already in Use

**Problem**: Port 3000 or 5173 already occupied
**Solution**:
```bash
# Find what's using the port
lsof -i :3000
lsof -i :5173

# Stop the conflicting service or change ports in docker-compose.yml
```

#### 4. Docker Build Fails

**Problem**: Docker build errors
**Solution**:
```bash
# Clean Docker cache
docker system prune -a

# Rebuild from scratch
docker-compose down
docker-compose up --build --force-recreate -d
```

#### 5. File Upload Not Working

**Problem**: Images not uploading or converting
**Solution**:
```bash
# Check file size limits (max 10MB per file)
# Check file types (only images allowed)
# Check browser console for errors
# Try with different images
```

### Health Checks

```bash
# Backend health
curl http://localhost:3000/health

# Frontend accessibility
curl -I http://localhost:5173

# Container status
docker ps

# Resource usage
docker stats
```

## 🔧 Configuration

### Environment Variables

**Backend**:
- `NODE_ENV`: `production` (default)
- `PORT`: `3000` (default)

**Frontend**:
- `VITE_API_URL`: `http://localhost:3000` (default)

### File Limits

- **Max file size**: 10MB per image
- **Max files**: 20 images per conversion
- **Supported formats**: All image types (JPEG, PNG, GIF, etc.)

## 📊 Performance

- **Memory usage**: ~50MB per container
- **Startup time**: ~10-15 seconds
- **Conversion speed**: Depends on image size and compression level
- **Concurrent users**: Handles multiple users simultaneously

## 🛡️ Security

- **File validation**: Only image files accepted
- **Size limits**: Prevents large file uploads
- **CORS enabled**: Controlled cross-origin requests
- **No file storage**: Files processed in memory only
- **Non-root containers**: Enhanced security

## 📝 API Documentation

### Endpoints

#### `GET /`
Returns API information and available endpoints.

#### `GET /health`
Returns application health status.

**Response**:
```json
{
  "status": "ok",
  "timestamp": "2025-10-25T04:24:03.405Z",
  "uptime": 545.015926916,
  "architecture": "2-tier"
}
```

#### `POST /convert`
Converts uploaded images to PDF.

**Request**:
- `Content-Type`: `multipart/form-data`
- `images`: Array of image files
- `compressionLevel`: `"normal"` | `"compressed"` | `"ultra"`
- `filename`: Custom PDF filename

**Response**:
- `Content-Type`: `application/pdf`
- `Content-Disposition`: `attachment; filename="filename.pdf"`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m "Add feature"`
6. Push: `git push origin feature-name`
7. Create a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Jill Ravaliya**
- Made with care and attention to detail
- Clean, modern, and efficient code
- Perfect 2-tier architecture implementation

---

## 🎯 Summary

This JPEG to PDF converter is a perfect example of a **clean 2-tier architecture**:

✅ **No Database Complexity**  
✅ **Stateless Operations**  
✅ **Easy Deployment**  
✅ **Modern Tech Stack**  
✅ **Docker Ready**  
✅ **Production Ready**  

**Perfect for**: File conversion, batch processing, and simple web applications that don't need data persistence.

---

*Happy converting! 🚀*