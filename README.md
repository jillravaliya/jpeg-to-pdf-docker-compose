# JPEG to PDF Converter – Docker Compose Orchestration


[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-19.2.0-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Latest-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Express](https://img.shields.io/badge/Express-4.18.2-000000?logo=express&logoColor=white)](https://expressjs.com/)

---

I thought I had it figured out.

After [learning Docker basics](https://github.com/jillravaliya/jpeg-to-pdf-dockerized-app), I could containerize anything. My frontend worked, backend worked, everything was isolated and reproducible.

**But here's what nobody tells you:**

Running containerized apps manually is... exhausting.

Every single time I wanted to start my app:

```bash
# Create network
docker network create jpeg-net

# Start backend
docker build -t backend ./backend
docker run -d --name backend --network jpeg-net -p 3000:3000 backend

# Start frontend
docker build -t frontend ./frontend
docker run -d --name frontend --network jpeg-net -p 5173:80 frontend
```

**That's 6 commands. Every. Single. Time.**

And if something failed? Start over from scratch.

Forgot to create the network first? Error.
Old containers still running? Port conflict.
Changed code? Rebuild everything manually.

I kept thinking: *"There has to be a better way."*

That's when I discovered **Docker Compose** — and everything changed.

---

## What This Taught Me

I wanted to build a simple image-to-PDF converter.

Sounds easy, right? Just containerize the code and run it.

But reality hit hard:

- Managing multiple containers manually
- Remembering all the docker run flags
- Network setup every single time
- Service startup order issues
- Environment variables scattered everywhere
- "Did I already create that network?"

I realized something important:

**Containerized apps that require 10 commands to start aren't production-ready — they're accidents waiting to happen.**

I needed to understand how to:
- Orchestrate multiple services together
- Define infrastructure as code
- Make complex setups simple
- Automate what I was doing manually

That's what led to this project.

---

## Architecture

```
Frontend (React + Vite + Nginx)
Port: 80
|
| → HTTP POST /convert
|
Backend (Node.js + Express + Sharp + PDFKit)  
Port: 3000
|
| → Stream PDF directly to browser
|
PDF Output (Memory only, no disk writes)
```

Two containers, one network, orchestrated by Docker Compose.

---

## The Journey

### **Step 1: Understanding the Problem**

I started by listing what I was doing manually every time:

```
docker network create jpeg-net
docker build backend image
docker run backend container with network flag
docker build frontend image  
docker run frontend container with network flag
set environment variables for each
remember all the port mappings
```

This wasn't sustainable.

### **Step 2: Project Setup**

First, I organized the project structure:

```bash
cd ~/Desktop/jpeg-to-pdf-compose
git init
git add .
git commit -m "Initial commit: Ready for orchestration"
```

My structure:
```
project/
├── backend/
│   ├── Dockerfile
│   ├── app.js
│   └── package.json
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── src/
└── docker-compose.yml  ← The orchestrator
```

### **Step 3: Writing docker-compose.yml**

This is where everything comes together.

I started simple:

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
```

Tested it:

```bash
docker-compose up
```

**Backend started!** 

### **Step 4: Adding Frontend Service** 

Extended the compose file:

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    networks:
      - app-network

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    networks:
      - app-network
    depends_on:
      - backend

networks:
  app-network:
    driver: bridge
```

Key learning: **Services communicate using service names as hostnames.**

So `http://backend:3000` works inside the Docker network.

### **Step 5: Environment Configuration** 

Added environment variables:

```yaml
frontend:
  environment:
    - VITE_API_URL=http://backend:3000
```

This tells the frontend where to find the backend.

### **Step 6: Health Checks & Restart Policies** 

Added monitoring:

```yaml
backend:
  healthcheck:
    test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]
    interval: 30s
    timeout: 10s
    retries: 3
  restart: unless-stopped
```

Now Docker monitors services and auto-restarts on failure.

### **Step 7: Final Testing** 

```bash
docker-compose up -d
docker-compose ps
```

Output:
```
NAME           STATUS                    PORTS
app-backend    Up (healthy)             0.0.0.0:3000->3000/tcp
app-frontend   Up (healthy)             0.0.0.0:80->80/tcp
```

Opened browser → `http://localhost`

**Everything worked perfectly.** 

---

## The Debugging Chronicles

Every error taught me something:

| Problem | What I Did | Solution |
|---------|-----------|----------|
| Port already allocated | `docker ps` to check running containers | `docker rm -f $(docker ps -aq)` to clean up |
| Backend service unhealthy | `docker-compose logs backend` | Fixed health check endpoint path |
| Frontend white screen | `docker-compose exec frontend sh` → checked nginx | Fixed `vite.config.js` build config |
| Cannot connect to backend | Used `localhost` instead of service name | Changed to `http://backend:3000` |
| depends_on not working | Read Docker docs | Added health checks for proper waiting |
| Old code running | Docker cached layers | `docker-compose build --no-cache` |
| YAML syntax errors | Indentation issues | Used spaces (not tabs), validated YAML |
| Network errors | Services on different networks | Defined custom bridge network |
| Environment vars not loading | Wrong YAML structure | Fixed indentation under `environment:` |

**Key takeaway:** YAML is strict. Indentation matters. Always check logs first.

---

## How to Run This Project

### Prerequisites

```bash
- Docker installed
- Docker Compose installed
```

That's it. No Node.js, no npm, nothing else needed.

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd jpeg-to-pdf-compose
```

### Running with Docker Compose

```bash
# Start everything (with logs)
docker-compose up

# Or start in background
docker-compose up -d
```

### Accessing the Application

Open your browser:
- **Frontend:** http://localhost
- **Backend API:** http://localhost:3000

### Viewing Logs

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service
docker-compose logs backend
```

### Checking Status

```bash
docker-compose ps
```

### Stopping Everything

```bash
docker-compose down
```

### Rebuilding After Changes

```bash
docker-compose up --build
```

---

## What I Learned

Docker Compose completely changed how I think about infrastructure.

### About Orchestration

Before Docker Compose, I thought in terms of individual containers:
- "How do I run this container?"
- "What flags do I need?"
- "Which ports should I expose?"

After Docker Compose, I think in terms of systems:
- "What services do I need?"
- "How do they depend on each other?"
- "How do they communicate?"

**That's a fundamental shift.**

### About Infrastructure as Code

The `docker-compose.yml` file isn't just configuration.

It's **executable documentation.**

Anyone can read it and understand:
- What services exist
- How they're connected
- What ports they use
- What environment they need

No README needed. The code explains itself.

### About Service Communication

Inside Docker networks, services use service names:
- `http://backend:3000` automatically resolves
- No hardcoded IPs
- No localhost confusion
- Same config for dev and production

This is how real microservices work.

### About Dependencies

`depends_on` taught me the difference between:
- Container *started* (Docker's default)
- Service *ready* (what you actually need)

Health checks bridge that gap.

### About YAML

I learned YAML the hard way:
- Indentation matters (spaces, not tabs)
- Structure is strict
- Syntax errors fail silently sometimes

But this strictness prevents mistakes.

### The Bigger Picture

Docker Compose isn't just about convenience.

It's about:
- **Reproducibility** - Same setup everywhere
- **Simplicity** - Complex systems made simple
- **Professionalism** - This is how real systems are built

From 6 manual commands to 1 automated command isn't just easier.

**It's the difference between a script and a system.**

---

## The Moment It Clicked

I was debugging networking for hours.
Frontend couldn't reach backend. I checked:

- Firewall rules
- Port mappings
- IP addresses
- CORS configuration

Nothing worked.

Then I looked at my fetch URL: http://localhost:3000
> Wait.

Inside a Docker container, localhost is the container itself.

Changed it to: http://backend:3000

**Boom. It worked.**

That's when I understood:
> Docker Compose creates an isolated network. Services find each other by name, not by localhost.
This wasn't a bug. This was proper microservice architecture.

---

## Why This Matters

For Me
I learned:

- How real systems are deployed
- How services communicate in production
- How to write reproducible infrastructure
- How to think in distributed systems

For Anyone Using This
You get:

- One-command setup
- Guaranteed reproducibility
- Same behavior everywhere
- Professional-grade architecture

No more "works on my machine."

---

## Tech Stack

### Backend
- Node.js 18 (Alpine)
- Express 4.18.2
- Multer 1.4.5 (file uploads)
- Sharp 0.32.0 (image processing)
- PDFKit 0.13.0 (PDF generation)

### Frontend
- React 18.2.0
- Vite 4.4.0
- Nginx (production server)

### DevOps
- Docker
- Docker Compose 3.8
- Bridge networking
- Health monitoring

---

## What's Next?

Right now, this runs perfectly on my laptop.

But what about:
- Making it accessible to anyone, anywhere?
- Automatic deployments when I push code?
- Running on a real domain with HTTPS?
- Scaling across multiple servers?

The next step:
- CI/CD pipelines (GitHub Actions)
- Cloud deployment (AWS/GCP/Azure)
- DNS configuration with custom domain
- Production monitoring and scaling

**Building a real website that lives on the internet.**

That's what I'm working towards.

---

## Connect With Me  

I’m actively learning, building, and seeking opportunities in **network engineering** and **cloud infrastructure**.  

- Email: **jillahir9999@gmail.com**  
- LinkedIn: [linkedin.com/in/jill-ravaliya-684a98264](https://linkedin.com/in/jill-ravaliya-684a98264)  
- GitHub: [github.com/jillravaliya](https://github.com/jillravaliya)  

**Open to:**  
- Entry-to-mid-level network engineering roles  
- Cloud infrastructure opportunities  
- Mentorship & collaboration  
- Professional networking  

---

### ⭐ If this project helped you understand Docker, give it a star!




