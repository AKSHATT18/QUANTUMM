# 🐳 QuantumShield Docker Setup Guide

This guide will help you set up and run the QuantumShield project using Docker containers.

## 📋 Prerequisites

- **Docker** (v20.10+)
- **Docker Compose** (v2.0+)
- **Make** (optional, for simplified commands)

### Install Docker

#### **Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### **macOS:**
```bash
brew install --cask docker
```

#### **Windows:**
Download Docker Desktop from [docker.com](https://docker.com)

## 🚀 Quick Start

### **1. Clone and Navigate**
```bash
git clone <your-repo-url>
cd QuantumShield
```

### **2. Quick Start (Recommended)**
```bash
# Using Make (if available)
make quick-start

# Or manually:
docker-compose -f docker-compose.dev.yml up -d
```

### **3. Access the Application**
- **Application**: http://localhost:5000
- **pgAdmin**: http://localhost:5050 (admin@quantumshield.dev / admin123)
- **Redis Commander**: http://localhost:8081

## 🔧 Detailed Setup

### **Development Environment**

```bash
# Start development environment with hot reloading
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f app

# Stop development environment
docker-compose -f docker-compose.dev.yml down
```

### **Production Environment**

```bash
# Start production environment
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop production environment
docker-compose down
```

## 📊 Available Services

| Service | Port | Description |
|---------|------|-------------|
| **Application** | 5000 | QuantumShield main application |
| **PostgreSQL** | 5432 | Database server |
| **Redis** | 6379 | Session storage and caching |
| **pgAdmin** | 5050 | Database management interface |
| **Redis Commander** | 8081 | Redis management interface |

## 🛠️ Management Commands

### **Using Make (Recommended)**

```bash
# Show all available commands
make help

# Development environment
make dev          # Start development
make logs-dev     # View development logs
make shell-dev    # Access development container
make db-shell-dev # Access development database

# Production environment
make up           # Start production
make logs         # View production logs
make shell        # Access production container
make db-shell     # Access production database

# General management
make status       # Show container status
make health       # Check service health
make restart      # Restart all services
make clean        # Remove all containers and images
```

### **Using Docker Compose Directly**

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart
```

## 🗄️ Database Management

### **Initialize Schema**
```bash
# Development
make db-init-dev

# Production
make db-init
```

### **Database Access**
```bash
# Development database shell
make db-shell-dev

# Production database shell
make db-shell

# Using pgAdmin
# Open http://localhost:5050
# Login: admin@quantumshield.dev / admin123
# Add server: postgres:5432, quantumshield, quantumshield, quantumshield123
```

### **Backup and Restore**
```bash
# Create backup
make db-backup

# Restore from backup
make db-restore
```

## 🔍 Monitoring and Debugging

### **Container Status**
```bash
# Show all containers
make status

# Check service health
make health

# View resource usage
make resources
```

### **Logs and Debugging**
```bash
# Application logs
make logs-dev      # Development
make logs          # Production

# Container shell access
make shell-dev     # Development
make shell         # Production
```

## 🚨 Troubleshooting

### **Common Issues**

#### **1. Port Already in Use**
```bash
# Check what's using the port
lsof -i :5000

# Kill the process
sudo kill -9 <PID>

# Or change ports in docker-compose files
```

#### **2. Database Connection Failed**
```bash
# Check database container status
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Restart database
docker-compose restart postgres
```

#### **3. Build Failures**
```bash
# Clean and rebuild
make clean
make build

# Or manually:
docker-compose down -v --rmi all
docker-compose build --no-cache
```

#### **4. Permission Issues**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Or run with sudo (not recommended for production)
sudo docker-compose up -d
```

### **Reset Everything**
```bash
# Complete cleanup
make clean

# Remove all Docker resources
docker system prune -a --volumes

# Rebuild from scratch
make build
make dev
```

## 🔧 Customization

### **Environment Variables**
Create a `.env` file to override defaults:

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:port/db
REDIS_URL=redis://host:port

# Application
PORT=5000
NODE_ENV=development
LOG_LEVEL=debug

# Quantum Model
QUANTUM_MODEL_QUBITS=8
ENCODED_QUBITS=4
PRIVACY_BUDGET=0.1
```

### **Port Configuration**
Modify ports in `docker-compose.yml`:

```yaml
ports:
  - "3000:5000"  # Change 3000 to your preferred port
```

### **Volume Mounts**
Add additional volumes for development:

```yaml
volumes:
  - ./config:/app/config
  - ./data:/app/data
```

## 📈 Performance Optimization

### **Resource Limits**
Add resource constraints in docker-compose:

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
```

### **Database Optimization**
```yaml
services:
  postgres:
    environment:
      POSTGRES_SHARED_BUFFERS: 256MB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 1GB
      POSTGRES_WORK_MEM: 4MB
```

## 🔒 Security Considerations

### **Production Security**
```bash
# Use strong passwords
# Change default credentials in docker-compose.yml

# Enable SSL for database connections
# Use secrets management for sensitive data

# Restrict network access
# Use internal networks only
```

### **Development Security**
```bash
# Don't expose database ports in production
# Use environment variables for secrets
# Regularly update base images
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Redis Docker Image](https://hub.docker.com/_/redis)

## 🆘 Getting Help

If you encounter issues:

1. **Check logs**: `make logs-dev` or `make logs`
2. **Verify status**: `make status`
3. **Check health**: `make health`
4. **Review this guide** for common solutions
5. **Check container logs** for specific error messages

---

**🎉 You're now ready to run QuantumShield with Docker!**

Start with: `make quick-start`
Then open: http://localhost:5000
