# QuantumGuard - Quantum-Enhanced Fraud Detection System

## Overview

QuantumGuard is a sophisticated fraud detection platform that combines quantum machine learning with federated learning to provide privacy-preserving financial fraud detection. The system uses quantum autoencoders for anomaly detection while enabling financial institutions to collaboratively train models without sharing sensitive data. Built with a modern full-stack architecture, it features real-time transaction monitoring, quantum circuit visualization, and comprehensive fraud alerting capabilities.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture
The client is built with React 18 using TypeScript and modern hooks patterns. The UI leverages shadcn/ui components built on Radix UI primitives for a consistent design system. State management is handled through TanStack Query for server state and React hooks for local state. The application uses Wouter for lightweight client-side routing and supports real-time updates through WebSocket connections. Styling is implemented with Tailwind CSS using a dark theme with custom color variables.

### Backend Architecture
The server is built on Express.js with TypeScript, following a RESTful API design. The architecture separates concerns into distinct layers: route handlers, business logic services, and data storage abstraction. Core services include a quantum machine learning simulator, fraud detection engine, and federated learning coordinator. The system uses WebSocket connections for real-time client updates and implements comprehensive error handling and logging middleware.

### Data Storage
The system uses an abstract storage interface (IStorage) that can be implemented with different backends. Currently includes an in-memory implementation for development and is configured for PostgreSQL with Drizzle ORM. The schema includes tables for users, transactions, quantum models, federated nodes, fraud alerts, and model metrics. Database migrations are managed through Drizzle Kit.

### Quantum Computing Simulation
Custom quantum simulator implements quantum gates (Hadamard, rotation gates, CNOT) and quantum state manipulation using classical computation. The QuantumAutoencoder class provides anomaly detection capabilities by learning normal transaction patterns. Quantum circuits are visualized in real-time with parameter tracking and reconstruction error monitoring.

### Federated Learning System
The FederatedLearningCoordinator manages distributed model training across multiple financial institutions. Implements differential privacy with configurable privacy budgets and secure aggregation protocols. Model parameters are aggregated using weighted averaging based on participant data sizes while maintaining privacy guarantees.

### Fraud Detection Engine
Combines quantum machine learning with traditional feature engineering for transaction analysis. Extracts features including transaction amount, time patterns, merchant categories, geographic risk, and velocity scoring. The quantum model detects anomalies by measuring reconstruction errors, while threshold-based alerting provides risk categorization.

### Real-time Communication
WebSocket server enables real-time updates for transaction monitoring, fraud alerts, and federated learning progress. Message validation uses Zod schemas for type safety. The client automatically reconnects on connection loss and handles real-time visualization updates.

### Security and Privacy
Implements differential privacy for federated learning with configurable epsilon values. Privacy budgets are tracked per participant to prevent privacy leakage. The system supports multiple privacy levels and includes secure aggregation protocols for model updates.

## External Dependencies

### Database
- **Neon Database**: PostgreSQL database service with connection pooling
- **Drizzle ORM**: Type-safe database toolkit for schema management and queries
- **Drizzle Kit**: CLI tool for database migrations and schema synchronization

### Frontend Libraries
- **React Query (TanStack)**: Server state management and caching
- **Radix UI**: Headless UI components for accessibility
- **Wouter**: Lightweight React router
- **Lucide React**: Icon library
- **date-fns**: Date manipulation utilities
- **Tailwind CSS**: Utility-first CSS framework

### Backend Dependencies
- **Express.js**: Web application framework
- **WebSocket (ws)**: Real-time bidirectional communication
- **Zod**: Runtime type validation
- **connect-pg-simple**: PostgreSQL session store

### Development Tools
- **Vite**: Build tool and development server
- **TypeScript**: Static type checking
- **ESBuild**: Fast JavaScript bundler
- **PostCSS**: CSS processing tool
- **Autoprefixer**: CSS vendor prefixing

### Replit Integration
- **@replit/vite-plugin-runtime-error-modal**: Development error overlay
- **@replit/vite-plugin-cartographer**: Development tooling for Replit environment