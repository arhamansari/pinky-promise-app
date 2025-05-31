# Pinky Promise App

A full-stack web application built with React frontend, Node.js backend, and PostgreSQL database, all containerized with Docker.

## 🏗️ Architecture

- **Frontend**: React application served with Nginx
- **Backend**: Node.js/Express API server
- **Database**: PostgreSQL with UUID extension
- **Deployment**: Docker Compose orchestration

## 📋 Prerequisites

Before running this application, ensure you have the following installed on your local machine:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)
- **Git**: [Install Git](https://git-scm.com/downloads)

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Ensure Docker is running
docker ps
```

## 🚀 Quick Start

### Option 1: Using Helper Scripts (Recommended)

```bash
git clone <repository-url>
cd pinky-promise-app
git checkout -b localdeployment origin/localdeployment

# Start the application (this handles everything automatically)
./start.sh

# Stop the application when done
./stop.sh
```

#### What the start script does:
1. ✅ Checks if Docker is running
2. 📝 Creates `.env` file from template (if it doesn't exist)
3. 🛑 Stops any existing containers
4. 🏗️ Builds and starts all services (database, backend, frontend)
5. ⏳ Waits for database to be ready
6. 🗃️ Initializes database schema automatically
7. 🎉 Shows success message with access URLs

#### Expected output when running `./start.sh`:
```
🚀 Starting Pinky Promise App...
==================================================
✅ Docker is running
📝 Creating environment file...
✅ Environment file created at deploy/.env
⚠️  Please edit deploy/.env with your configuration before production use!
🛑 Stopping existing containers...
🏗️  Building and starting services...
[Docker build output...]
⏳ Waiting for database to be ready...
🗃️  Initializing database schema...
CREATE EXTENSION
CREATE TABLE
==================================================
🎉 Application is now running!

📱 Frontend: http://localhost:80
🔧 Backend API: http://localhost:5001
🗄️  Database: localhost:5432

📊 Check status: docker-compose -f deploy/docker-compose.yml ps
📋 View logs: docker-compose -f deploy/docker-compose.yml logs -f
🛑 Stop app: docker-compose -f deploy/docker-compose.yml down
==================================================
```

### Option 2: Manual Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd pinky-promise-app
```

### 2. Environment Configuration

Create environment file for deployment:

```bash
cp deploy/.env.example deploy/.env
```

Edit `deploy/.env` with your configuration:

```env
# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=pinky_promise

# JWT Secrets (change these in production)
JWT_SECRET=your-jwt-secret-key
JWT_REFRESH_SECRET=your-jwt-refresh-secret-key

# ReCAPTCHA (optional)
RECAPTCHA_SECRET_KEY=your-recaptcha-secret
```

### 3. Build and Run

```bash
# Build and start all services
docker-compose -f deploy/docker-compose.yml up --build -d

# View logs (optional)
docker-compose -f deploy/docker-compose.yml logs -f
```

### 4. Initialize Database

Apply the database schema:

```bash
docker exec -i pinky-promise-db psql -U postgres -d pinky_promise < backend/schema.sql
```

### 5. Access the Application

- **Frontend**: [http://localhost](http://localhost)
- **Backend API**: [http://localhost:5001](http://localhost:5001)
- **Database**: `localhost:5432`

## 📁 Project Structure

```
pinky-promise-app/
├── README.md                    # This file
├── backend/                     # Node.js API server
│   ├── server.js               # Main server file
│   ├── package.json            # Backend dependencies
│   ├── schema.sql              # Database schema
│   ├── routes/                 # API routes
│   └── middleware/             # Express middleware
├── pinky-promise-app/          # React frontend
│   ├── src/                    # React source code
│   ├── public/                 # Static assets
│   └── package.json            # Frontend dependencies
└── deploy/                     # Docker deployment
    ├── docker-compose.yml      # Service orchestration
    ├── .env                    # Environment variables
    ├── backend/
    │   └── Dockerfile          # Backend container config
    └── frontend/
        ├── Dockerfile          # Frontend container config
        └── nginx.conf          # Nginx configuration
```

## 🐳 Docker Services

### Database (PostgreSQL)
- **Container**: `pinky-promise-db`
- **Port**: `5432`
- **Image**: `postgres:14-alpine`
- **Volume**: `postgres_data` (persistent storage)

### Backend (Node.js API)
- **Container**: `pinky-promise-backend`
- **Port**: `5001`
- **Build Context**: `backend/`
- **Health Check**: HTTP check on `/`

### Frontend (React + Nginx)
- **Container**: `pinky-promise-frontend`
- **Port**: `80`
- **Build Context**: `pinky-promise-app/`
- **Multi-stage**: Build with Node.js, serve with Nginx

## 🎯 Script Execution Guide

### Running the Start Script

Make the script executable (if needed):
```bash
chmod +x start.sh
```

Execute the start script:
```bash
./start.sh
```

### Verifying the Application is Running

After running `./start.sh`, verify everything is working:

#### 1. Check Container Status
```bash
docker-compose -f deploy/docker-compose.yml ps
```

**Expected output:**
```
NAME                     IMAGE                COMMAND                  SERVICE    CREATED        STATUS                 PORTS
pinky-promise-backend    deploy-backend       "docker-entrypoint.s…"   backend    2 minutes ago  Up 2 minutes (healthy) 0.0.0.0:5001->5001/tcp
pinky-promise-db         postgres:14-alpine   "docker-entrypoint.s…"   db         2 minutes ago  Up 2 minutes (healthy) 0.0.0.0:5432->5432/tcp
pinky-promise-frontend   deploy-frontend      "/docker-entrypoint.…"   frontend   2 minutes ago  Up 2 minutes           0.0.0.0:80->80/tcp
```

#### 2. Test Database Connection
```bash
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "\dt"
```

**Expected output:**
```
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | users | table | postgres
(1 row)
```

#### 3. Test Backend API
```bash
curl http://localhost:5001
```

**Expected output:** Should return a response from your API (varies based on implementation)

#### 4. Test Frontend
```bash
curl -I http://localhost
```

**Expected output:**
```
HTTP/1.1 200 OK
Server: nginx/1.24.0
Content-Type: text/html
...
```

#### 5. Test Database Query
```bash
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT COUNT(*) FROM users;"
```

**Expected output:**
```
 count 
-------
     0
(1 row)
```

### Running the Stop Script

To stop all services:
```bash
./stop.sh
```

**Expected output:**
```
🛑 Stopping Pinky Promise App...
========================================
[+] Running 4/4
 ✔ Container pinky-promise-frontend  Removed
 ✔ Container pinky-promise-backend   Removed
 ✔ Container pinky-promise-db        Removed
 ✔ Network deploy_app-network        Removed
✅ All containers stopped
📊 To check status: docker-compose -f deploy/docker-compose.yml ps
🗑️  To remove volumes (delete data): docker-compose -f deploy/docker-compose.yml down --volumes
========================================
```

### Verifying Stop

Check that all containers are stopped:
```bash
docker-compose -f deploy/docker-compose.yml ps
```

**Expected output:** Should show no running containers or empty output.

### Accessing the Application

Once the start script completes successfully, you can access:

- **Frontend Application**: Open [http://localhost](http://localhost) in your web browser
- **Backend API**: Test API endpoints at [http://localhost:5001](http://localhost:5001)
- **Database**: Connect using any PostgreSQL client to `localhost:5432`

### 📋 Quick Verification Checklist

After running `./start.sh`, use this checklist to ensure everything is working:

- [ ] **Containers Running**: `docker-compose -f deploy/docker-compose.yml ps` shows all 3 services as "Up"
- [ ] **Database Ready**: `docker exec pinky-promise-db pg_isready -U postgres` returns "accepting connections"
- [ ] **Schema Applied**: `docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "\dt"` shows "users" table
- [ ] **Frontend Accessible**: Browser opens [http://localhost](http://localhost) successfully
- [ ] **Backend Responsive**: `curl http://localhost:5001` returns a response
- [ ] **Database Queryable**: `docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT COUNT(*) FROM users;"` works

If all items are checked ✅, your application is ready to use!

### Common Script Errors and Solutions

**Error: `Docker is not running`**
```bash
❌ Error: Docker is not running. Please start Docker and try again.
```
**Solution:** Start Docker Desktop and wait for it to be fully loaded.

**Error: `Permission denied`**
```bash
./start.sh: Permission denied
```
**Solution:** Make the script executable:
```bash
chmod +x start.sh stop.sh
```

**Error: `Port already in use`**
```bash
Error response from daemon: driver failed programming external connectivity
```
**Solution:** Stop any services using ports 80, 5001, or 5432:
```bash
# Find what's using the ports
lsof -i :80 -i :5001 -i :5432

# Kill the processes or stop other Docker containers
docker stop $(docker ps -q)
```

## 🛠️ Development Commands

### Managing Services

```bash
# Start services
docker-compose -f deploy/docker-compose.yml up -d

# Stop services
docker-compose -f deploy/docker-compose.yml down

# Stop and remove volumes (⚠️ deletes database data)
docker-compose -f deploy/docker-compose.yml down --volumes

# View service status
docker-compose -f deploy/docker-compose.yml ps

# View logs
docker-compose -f deploy/docker-compose.yml logs [service-name]

# Rebuild specific service
docker-compose -f deploy/docker-compose.yml up --build [service-name]
```

### Database Operations

```bash
# Connect to database
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise

# Run SQL commands
docker exec -it pinky-promise-db psql -U postgres -d pinky_promise -c "SELECT * FROM users;"

# Backup database
docker exec pinky-promise-db pg_dump -U postgres pinky_promise > backup.sql

# Restore database
docker exec -i pinky-promise-db psql -U postgres -d pinky_promise < backup.sql
```

### Useful SQL Commands

```sql
-- List all tables
\dt

-- Describe users table
\d users

-- View all users
SELECT id, name, email, created_at FROM users ORDER BY created_at DESC;

-- Count total users
SELECT COUNT(*) FROM users;

-- Exit psql
\q
```

## 🔧 Troubleshooting

### Common Issues

**1. Port Already in Use**
```bash
# Check what's using the port
lsof -i :80
lsof -i :5001
lsof -i :5432

# Kill process using port (replace PID)
kill -9 <PID>
```

**2. Database Connection Issues**
```bash
# Check if database is healthy
docker-compose -f deploy/docker-compose.yml ps

# View database logs
docker-compose -f deploy/docker-compose.yml logs db

# Restart database service
docker-compose -f deploy/docker-compose.yml restart db
```

**3. Build Failures**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose -f deploy/docker-compose.yml build --no-cache
```

**4. Permission Issues (macOS/Linux)**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Health Checks

```bash
# Check all services are running
docker-compose -f deploy/docker-compose.yml ps

# Test backend API
curl http://localhost:5001

# Test frontend
curl http://localhost

# Test database connection
docker exec pinky-promise-db pg_isready -U postgres
```

## 🔐 Security Notes

- **Default passwords**: Change default database passwords in production
- **JWT secrets**: Use strong, unique secrets for JWT tokens
- **Environment variables**: Never commit `.env` files with real secrets
- **Database access**: Database is only accessible from Docker network by default

## 📝 API Endpoints

Once running, the backend API will be available at `http://localhost:5001` with endpoints like:

- `GET /api/users` - Get all users
- `POST /api/users` - Create new user
- `GET /api/users/:id` - Get specific user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

*(Actual endpoints may vary based on your implementation)*

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [React Documentation](https://reactjs.org/docs/)
- [Node.js Documentation](https://nodejs.org/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker
5. Submit a pull request

## 📄 License

[Add your license information here]

---

**Note**: This application is configured for development use. For production deployment, additional security measures, environment configurations, and performance optimizations should be implemented.

