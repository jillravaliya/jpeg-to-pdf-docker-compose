# JPEG to PDF Converter

A modern, Dockerized web application that converts multiple JPEG images into a single PDF document with compression options. Built with React frontend and Node.js backend.

## Features

- 🖼️ **Multi-image Upload**: Drag and drop or browse to select multiple images
- 📄 **PDF Generation**: Convert images to a single PDF document
- 🗜️ **Compression Options**: Choose from Normal, Compressed, or Ultra compression levels
- 🌙 **Dark Mode**: Toggle between light and dark themes
- 📱 **Responsive Design**: Works on desktop and mobile devices
- 🐳 **Dockerized**: Easy deployment with Docker Compose
- ⚡ **Fast Processing**: Stream-based PDF generation for optimal performance

## Tech Stack

### Frontend
- **React 18** - Modern UI library
- **Vite** - Fast build tool and dev server
- **CSS3** - Custom styling with animations

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **PDFKit** - PDF generation library
- **Sharp** - Image processing library
- **Multer** - File upload handling

### Infrastructure
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Nginx** - Web server for frontend

## Prerequisites

Before running this application, make sure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0+)
- [Git](https://git-scm.com/downloads)

## Quick Start

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd jpeg-to-pdf-docker-compose
```

### 2. Build and Run with Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d
```

### 3. Access the Application

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health

### 4. Stop the Application

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Development Setup

### Backend Development

```bash
cd backend

# Install dependencies
npm install

# Start development server
npm run dev
```

### Frontend Development

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

## Supabase Integration (Optional)

While this application works standalone, you can integrate Supabase for additional features like user authentication, file storage, or usage analytics.

### Setting up Supabase

1. **Create a Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Note your project URL and API key

2. **Environment Variables**
   
   Create a `.env` file in the root directory:
   
   ```env
   # Supabase Configuration
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   
   # Optional: For user authentication
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   ```

3. **Update Docker Compose**
   
   Add environment variables to your `docker-compose.yml`:
   
   ```yaml
   services:
     backend:
       # ... existing configuration
       environment:
         - NODE_ENV=production
         - PORT=3000
         - SUPABASE_URL=${SUPABASE_URL}
         - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
   
     frontend:
       # ... existing configuration
       environment:
         - VITE_API_URL=http://localhost:3000
         - VITE_SUPABASE_URL=${SUPABASE_URL}
         - VITE_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
   ```

4. **Install Supabase Client**
   
   ```bash
   # Backend
   cd backend
   npm install @supabase/supabase-js
   
   # Frontend
   cd frontend
   npm install @supabase/supabase-js
   ```

### Example Supabase Integration

Here's how you could add user authentication and file history:

**Backend (`backend/app.js`)**:
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
)

// Add user authentication middleware
const authenticateUser = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token) return res.status(401).json({ error: 'No token provided' })
  
  try {
    const { data: { user }, error } = await supabase.auth.getUser(token)
    if (error) throw error
    req.user = user
    next()
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' })
  }
}

// Protected route example
app.post("/convert", authenticateUser, upload.array("images"), async (req, res) => {
  // ... existing conversion logic
  
  // Log conversion to Supabase
  await supabase
    .from('conversions')
    .insert({
      user_id: req.user.id,
      filename: sanitizedFilename,
      file_count: req.files.length,
      compression_level: compressionLevel,
      created_at: new Date().toISOString()
    })
})
```

**Frontend (`frontend/src/App.jsx`)**:
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

// Add authentication state
const [user, setUser] = useState(null)

useEffect(() => {
  // Check for existing session
  supabase.auth.getSession().then(({ data: { session } }) => {
    setUser(session?.user ?? null)
  })

  // Listen for auth changes
  const { data: { subscription } } = supabase.auth.onAuthStateChange(
    (event, session) => {
      setUser(session?.user ?? null)
    }
  )

  return () => subscription.unsubscribe()
}, [])

// Sign in function
const signIn = async () => {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google'
  })
  if (error) console.error('Error:', error.message)
}
```

## API Endpoints

### POST `/convert`
Convert multiple images to PDF.

**Request:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Body:
  - `images`: Array of image files (max 20 files, 10MB each)
  - `compressionLevel`: `"normal"` | `"compressed"` | `"ultra"`
  - `filename`: Custom filename for the PDF

**Response:**
- Content-Type: `application/pdf`
- Body: PDF file stream

### GET `/health`
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 123.456
}
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `PORT` | Backend port | `3000` |
| `VITE_API_URL` | Backend API URL | `http://localhost:3000` |

### Docker Configuration

The application uses multi-stage Docker builds for optimal image sizes:

- **Backend**: Node.js Alpine with non-root user
- **Frontend**: Nginx Alpine with optimized configuration

## File Structure

```
jpeg-to-pdf-docker-compose/
├── backend/
│   ├── app.js                 # Main backend application
│   ├── package.json           # Backend dependencies
│   ├── Dockerfile            # Backend container config
│   └── .dockerignore         # Docker ignore file
├── frontend/
│   ├── src/
│   │   ├── App.jsx           # Main React component
│   │   ├── App.css           # Application styles
│   │   └── main.jsx          # React entry point
│   ├── index.html            # HTML template
│   ├── package.json          # Frontend dependencies
│   ├── vite.config.js        # Vite configuration
│   ├── nginx.conf            # Nginx configuration
│   ├── Dockerfile            # Frontend container config
│   └── .dockerignore         # Docker ignore file
├── docker-compose.yml        # Docker Compose configuration
└── README.md                 # This file
```

## Performance Optimization

### Backend Optimizations
- Memory-only file processing (no disk writes)
- Stream-based PDF generation
- Image compression with Sharp
- File size and count limits
- Error handling middleware

### Frontend Optimizations
- Code splitting with Vite
- Gzip compression in Nginx
- Static asset caching
- Responsive design
- Dark mode support

### Docker Optimizations
- Multi-stage builds
- Non-root users for security
- Health checks
- Optimized layer caching
- Minimal base images (Alpine)

## Security Features

- File type validation (images only)
- File size limits (10MB per file)
- File count limits (20 files max)
- Filename sanitization
- Non-root Docker users
- Security headers in Nginx
- CORS configuration

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   lsof -i :3000
   lsof -i :5173
   
   # Kill the process or change ports in docker-compose.yml
   ```

2. **Docker Build Fails**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

3. **Frontend Can't Connect to Backend**
   - Check if backend is running: `docker-compose ps`
   - Verify environment variables in docker-compose.yml
   - Check browser console for CORS errors

4. **File Upload Fails**
   - Ensure files are images (JPEG, PNG, etc.)
   - Check file size (max 10MB per file)
   - Verify file count (max 20 files)

### Logs and Debugging

```bash
# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs backend
docker-compose logs frontend

# Follow logs in real-time
docker-compose logs -f
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Commit your changes: `git commit -m 'Add feature'`
6. Push to the branch: `git push origin feature-name`
7. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Search existing issues in the repository
3. Create a new issue with detailed information
4. Include logs and error messages

## Changelog

### Version 1.0.0
- Initial release
- Multi-image to PDF conversion
- Compression options
- Docker containerization
- Responsive design
- Dark mode support

---

Made with ❤️ by Jill Ravaliya
