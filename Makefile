# QuantumShield Docker Management Makefile

.PHONY: help build up down logs clean restart dev prod shell db-shell redis-shell

# Default target
help:
	@echo "🚀 QuantumShield Docker Management Commands"
	@echo ""
	@echo "📦 Build & Setup:"
	@echo "  make build     - Build all Docker images"
	@echo "  make up        - Start production environment"
	@echo "  make dev       - Start development environment"
	@echo "  make down      - Stop all containers"
	@echo ""
	@echo "🔧 Management:"
	@echo "  make logs      - View application logs"
	@echo "  make restart   - Restart all services"
	@echo "  make clean     - Remove containers, images, and volumes"
	@echo ""
	@echo "🐚 Shell Access:"
	@echo "  make shell     - Access application container shell"
	@echo "  make db-shell  - Access PostgreSQL database shell"
	@echo "  make redis-shell - Access Redis shell"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  make status    - Show container status"
	@echo "  make health    - Check service health"

# Build all images
build:
	@echo "🔨 Building QuantumShield Docker images..."
	docker-compose build --no-cache
	@echo "✅ Build completed!"

# Start production environment
up:
	@echo "🚀 Starting QuantumShield production environment..."
	docker-compose up -d
	@echo "✅ Production environment started!"
	@echo "🌐 Application: http://localhost:5000"
	@echo "🗄️  Database: localhost:5432"
	@echo "🔴 Redis: localhost:6379"

# Start development environment
dev:
	@echo "🔬 Starting QuantumShield development environment..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ Development environment started!"
	@echo "🌐 Application: http://localhost:5000"
	@echo "🗄️  Database: localhost:5432"
	@echo "🔴 Redis: localhost:6379"
	@echo "📊 pgAdmin: http://localhost:5050 (admin@quantumshield.dev / admin123)"
	@echo "🔍 Redis Commander: http://localhost:8081"

# Stop all containers
down:
	@echo "🛑 Stopping QuantumShield containers..."
	docker-compose down
	docker-compose -f docker-compose.dev.yml down
	@echo "✅ All containers stopped!"

# View logs
logs:
	@echo "📋 Application logs:"
	docker-compose logs -f app

# View development logs
logs-dev:
	@echo "📋 Development logs:"
	docker-compose -f docker-compose.dev.yml logs -f app

# Restart services
restart:
	@echo "🔄 Restarting QuantumShield services..."
	docker-compose restart
	@echo "✅ Services restarted!"

# Clean everything
clean:
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down -v --rmi all
	docker-compose -f docker-compose.dev.yml down -v --rmi all
	docker system prune -f
	@echo "✅ Cleanup completed!"

# Access application container shell
shell:
	@echo "🐚 Accessing application container shell..."
	docker-compose exec app sh

# Access development container shell
shell-dev:
	@echo "🐚 Accessing development container shell..."
	docker-compose -f docker-compose.dev.yml exec app sh

# Access database shell
db-shell:
	@echo "🗄️ Accessing PostgreSQL database shell..."
	docker-compose exec postgres psql -U quantumshield -d quantumshield

# Access development database shell
db-shell-dev:
	@echo "🗄️ Accessing development database shell..."
	docker-compose -f docker-compose.dev.yml exec postgres psql -U quantumshield -d quantumshield_dev

# Access Redis shell
redis-shell:
	@echo "🔴 Accessing Redis shell..."
	docker-compose exec redis redis-cli

# Access development Redis shell
redis-shell-dev:
	@echo "🔴 Accessing development Redis shell..."
	docker-compose -f docker-compose.dev.yml exec redis redis-cli

# Show container status
status:
	@echo "📊 Container Status:"
	docker-compose ps
	@echo ""
	@echo "📊 Development Container Status:"
	docker-compose -f docker-compose.dev.yml ps

# Check service health
health:
	@echo "🏥 Checking service health..."
	@echo "Application:"
	@curl -s http://localhost:5000/api/health || echo "❌ Application not responding"
	@echo ""
	@echo "Database:"
	@docker-compose exec postgres pg_isready -U quantumshield -d quantumshield || echo "❌ Database not responding"
	@echo ""
	@echo "Redis:"
	@docker-compose exec redis redis-cli ping || echo "❌ Redis not responding"

# Initialize database schema
db-init:
	@echo "🗄️ Initializing database schema..."
	docker-compose exec app npm run db:push
	@echo "✅ Database schema initialized!"

# Initialize development database schema
db-init-dev:
	@echo "🗄️ Initializing development database schema..."
	docker-compose -f docker-compose.dev.yml exec app npm run db:push
	@echo "✅ Development database schema initialized!"

# Backup database
db-backup:
	@echo "💾 Creating database backup..."
	docker-compose exec postgres pg_dump -U quantumshield quantumshield > backup_$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup created!"

# Restore database from backup
db-restore:
	@echo "📥 Restoring database from backup..."
	@read -p "Enter backup filename: " backup_file; \
	docker-compose exec -T postgres psql -U quantumshield -d quantumshield < $$backup_file
	@echo "✅ Database restored!"

# Show resource usage
resources:
	@echo "📊 Docker resource usage:"
	docker stats --no-stream

# Quick start (build + dev)
quick-start: build dev
	@echo "🎉 QuantumShield is ready!"
	@echo "🌐 Open http://localhost:5000 in your browser"
	@echo "📊 Monitor with: make logs-dev"

# Production deployment
deploy: build up
	@echo "🚀 QuantumShield deployed to production!"
	@echo "🌐 Application: http://localhost:5000"
	@echo "📊 Monitor with: make logs"
