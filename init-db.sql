-- QuantumShield Database Initialization Script
-- This script runs when the PostgreSQL container starts for the first time

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create database if it doesn't exist (this will be handled by POSTGRES_DB env var)
-- The database 'quantumshield' should already exist from environment variables

-- Set timezone
SET timezone = 'UTC';

-- Create custom types if needed
DO $$ BEGIN
    CREATE TYPE alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create tables (these will be created by Drizzle ORM, but we can add some initial data)
-- The actual table creation is handled by the application's database migration system

-- Insert some initial federated nodes for testing
INSERT INTO federated_nodes (id, name, institution_type, is_online, model_sync_progress, latency, privacy_level, last_seen) 
VALUES 
    (uuid_generate_v4(), 'Bank Alpha', 'Commercial Bank', true, 0.98, 24.5, 0.997, NOW()),
    (uuid_generate_v4(), 'Credit Union Beta', 'Credit Union', true, 0.94, 31.2, 0.995, NOW()),
    (uuid_generate_v4(), 'FinTech Gamma', 'FinTech', true, 0.96, 18.7, 0.998, NOW()),
    (uuid_generate_v4(), 'Investment Bank Delta', 'Investment Bank', true, 0.92, 45.1, 0.993, NOW()),
    (uuid_generate_v4(), 'Regional Bank Epsilon', 'Regional Bank', true, 0.89, 67.3, 0.991, NOW())
ON CONFLICT DO NOTHING;

-- Insert initial quantum model
INSERT INTO quantum_models (id, name, architecture, parameters, training_epochs, reconstruction_error, accuracy, is_active, created_at, updated_at)
VALUES (
    uuid_generate_v4(),
    'Quantum Fraud Autoencoder v1.0',
    '{"qubits": 8, "encodedQubits": 4, "layers": 3, "gates": ["H", "RY", "CNOT"]}',
    '[0.785, 1.571, 2.356, 0.393, 1.178, 0.785, 1.963, 0.589, 0.785, 1.571, 2.356, 0.393, 1.178, 0.785, 1.963, 0.589, 0.785, 1.571, 2.356, 0.393, 1.178, 0.785, 1.963, 0.589, 0.785, 1.571, 2.356, 0.393, 1.178, 0.785, 1.963, 0.589]',
    150,
    0.087,
    0.924,
    true,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- Insert sample transactions for testing
INSERT INTO transactions (id, amount, from_account, to_account, institution_id, timestamp, features, risk_score, is_approved, is_fraud)
VALUES 
    (uuid_generate_v4(), 1250.75, 'ACC001', 'ACC002', 'BANK_ALPHA', NOW() - INTERVAL '1 hour', '{"amount": 1250.75, "timeOfDay": 14.5, "dayOfWeek": 3, "merchantCategory": 2, "geographicRisk": 0.3, "velocityScore": 0.4, "accountAge": 180, "historicalPattern": 0.7}', 0.15, true, false),
    (uuid_generate_v4(), 8750.00, 'ACC003', 'ACC004', 'BANK_ALPHA', NOW() - INTERVAL '30 minutes', '{"amount": 8750.00, "timeOfDay": 15.0, "dayOfWeek": 3, "merchantCategory": 5, "geographicRisk": 0.2, "velocityScore": 0.3, "accountAge": 365, "historicalPattern": 0.8}', 0.25, true, false),
    (uuid_generate_v4(), 25000.00, 'ACC005', 'ACC006', 'BANK_ALPHA', NOW() - INTERVAL '15 minutes', '{"amount": 25000.00, "timeOfDay": 15.5, "dayOfWeek": 3, "merchantCategory": 8, "geographicRisk": 0.8, "velocityScore": 0.9, "accountAge": 15, "historicalPattern": 0.2}', 0.85, false, true),
    (uuid_generate_v4(), 500.00, 'ACC007', 'ACC008', 'BANK_ALPHA', NOW() - INTERVAL '5 minutes', '{"amount": 500.00, "timeOfDay": 16.0, "dayOfWeek": 3, "merchantCategory": 1, "geographicRisk": 0.1, "velocityScore": 0.2, "accountAge": 730, "historicalPattern": 0.9}', 0.08, true, false),
    (uuid_generate_v4(), 15000.00, 'ACC009', 'ACC010', 'BANK_ALPHA', NOW(), '{"amount": 15000.00, "timeOfDay": 16.5, "dayOfWeek": 3, "merchantCategory": 7, "geographicRisk": 0.9, "velocityScore": 0.95, "accountAge": 5, "historicalPattern": 0.1}', 0.92, false, true)
ON CONFLICT DO NOTHING;

-- Insert sample fraud alerts
INSERT INTO fraud_alerts (id, transaction_id, alert_type, risk_score, quantum_confidence, description, is_active, created_at)
SELECT 
    uuid_generate_v4(),
    t.id,
    CASE 
        WHEN t.risk_score > 0.8 THEN 'critical_risk'
        WHEN t.risk_score > 0.6 THEN 'high_risk'
        WHEN t.risk_score > 0.4 THEN 'medium_risk'
        ELSE 'low_risk'
    END,
    t.risk_score,
    GREATEST(0.5, t.risk_score + (RANDOM() - 0.5) * 0.2),
    CASE 
        WHEN t.risk_score > 0.8 THEN 'Critical fraud risk detected with high quantum confidence'
        WHEN t.risk_score > 0.6 THEN 'High fraud probability based on quantum pattern analysis'
        WHEN t.risk_score > 0.4 THEN 'Moderate fraud risk requiring manual review'
        ELSE 'Low fraud probability - monitoring recommended'
    END,
    true,
    t.timestamp
FROM transactions t
WHERE t.risk_score > 0.3
ON CONFLICT DO NOTHING;

-- Insert model metrics
INSERT INTO model_metrics (id, model_id, accuracy, precision, recall, f1_score, false_positive_rate, timestamp)
SELECT 
    uuid_generate_v4(),
    qm.id,
    0.924,
    0.92,
    0.89,
    0.88,
    0.032,
    NOW()
FROM quantum_models qm
WHERE qm.is_active = true
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON transactions(timestamp);
CREATE INDEX IF NOT EXISTS idx_transactions_institution ON transactions(institution_id);
CREATE INDEX IF NOT EXISTS idx_fraud_alerts_transaction ON fraud_alerts(transaction_id);
CREATE INDEX IF NOT EXISTS idx_federated_nodes_online ON federated_nodes(is_online);

-- Grant permissions (if needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO quantumshield;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO quantumshield;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'QuantumShield database initialization completed successfully!';
    RAISE NOTICE 'Database: %', current_database();
    RAISE NOTICE 'User: %', current_user;
    RAISE NOTICE 'Timestamp: %', NOW();
END $$;
