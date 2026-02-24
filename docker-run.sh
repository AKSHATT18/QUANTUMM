#!/bin/bash

# QuantumShield Docker Runner Script
# This script provides easy commands to manage the QuantumShield Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose and try again."
        exit 1
    fi
}

# Function to get docker-compose command
get_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo "docker compose"
    fi
}

# Main script logic
case "${1:-help}" in
    "help"|"-h"|"--help")
        echo -e "${BLUE}🚀 QuantumShield Docker Runner Script${NC}"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  dev         - Start development environment"
        echo "  prod        - Start production environment"
        echo "  stop        - Stop all environments"
        echo "  logs        - View application logs"
        echo "  logs-dev    - View development logs"
        echo "  build       - Build Docker images"
        echo "  clean       - Remove all containers and images"
        echo "  status      - Show container status"
        echo "  shell       - Access application container shell"
        echo "  db-shell    - Access database shell"
        echo "  health      - Check service health"
        echo "  help        - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 dev      - Start development environment"
        echo "  $0 prod     - Start production environment"
        echo "  $0 logs     - View logs"
        echo ""
        ;;
    
    "dev")
        print_info "Starting QuantumShield development environment..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD -f docker-compose.dev.yml up -d
        
        print_status "Development environment started!"
        echo "🌐 Application: http://localhost:5000"
        echo "🗄️  Database: localhost:5432"
        echo "🔴 Redis: localhost:6379"
        echo "📊 pgAdmin: http://localhost:5050 (admin@quantumshield.dev / admin123)"
        echo "🔍 Redis Commander: http://localhost:8081"
        echo ""
        print_info "View logs with: $0 logs-dev"
        ;;
    
    "prod")
        print_info "Starting QuantumShield production environment..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD up -d
        
        print_status "Production environment started!"
        echo "🌐 Application: http://localhost:5000"
        echo "🗄️  Database: localhost:5432"
        echo "🔴 Redis: localhost:6379"
        echo ""
        print_info "View logs with: $0 logs"
        ;;
    
    "stop")
        print_info "Stopping all QuantumShield environments..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD down
        $COMPOSE_CMD -f docker-compose.dev.yml down
        
        print_status "All environments stopped!"
        ;;
    
    "logs")
        print_info "Viewing production logs..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD logs -f app
        ;;
    
    "logs-dev")
        print_info "Viewing development logs..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD -f docker-compose.dev.yml logs -f app
        ;;
    
    "build")
        print_info "Building QuantumShield Docker images..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD build --no-cache
        
        print_status "Build completed!"
        ;;
    
    "clean")
        print_warning "This will remove ALL containers, images, and volumes!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cleaning up Docker resources..."
            check_docker
            check_docker_compose
            
            COMPOSE_CMD=$(get_docker_compose)
            $COMPOSE_CMD down -v --rmi all
            $COMPOSE_CMD -f docker-compose.dev.yml down -v --rmi all
            docker system prune -f
            
            print_status "Cleanup completed!"
        else
            print_info "Cleanup cancelled."
        fi
        ;;
    
    "status")
        print_info "Container status:"
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        echo "Production containers:"
        $COMPOSE_CMD ps
        echo ""
        echo "Development containers:"
        $COMPOSE_CMD -f docker-compose.dev.yml ps
        ;;
    
    "shell")
        print_info "Accessing production application container..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD exec app sh
        ;;
    
    "shell-dev")
        print_info "Accessing development application container..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD -f docker-compose.dev.yml exec app sh
        ;;
    
    "db-shell")
        print_info "Accessing production database..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD exec postgres psql -U quantumshield -d quantumshield
        ;;
    
    "db-shell-dev")
        print_info "Accessing development database..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        $COMPOSE_CMD -f docker-compose.dev.yml exec postgres psql -U quantumshield -d quantumshield_dev
        ;;
    
    "health")
        print_info "Checking service health..."
        check_docker
        check_docker_compose
        
        COMPOSE_CMD=$(get_docker_compose)
        
        echo "Application:"
        if curl -s http://localhost:5000/api/health > /dev/null; then
            print_status "Application is healthy"
        else
            print_error "Application is not responding"
        fi
        
        echo "Database:"
        if $COMPOSE_CMD exec postgres pg_isready -U quantumshield -d quantumshield > /dev/null 2>&1; then
            print_status "Database is healthy"
        else
            print_error "Database is not responding"
        fi
        
        echo "Redis:"
        if $COMPOSE_CMD exec redis redis-cli ping > /dev/null 2>&1; then
            print_status "Redis is healthy"
        else
            print_error "Redis is not responding"
        fi
        ;;
    
    *)
        print_error "Unknown command: $1"
        echo ""
        echo "Use '$0 help' to see available commands."
        exit 1
        ;;
esac
