-- DB Version: 17
-- OS Type: linux
-- DB Type: web
-- Total Memory (RAM): 16 GB
-- Data Storage: ssd

ALTER SYSTEM SET
 max_connections = '200';
ALTER SYSTEM SET
 shared_buffers = '4GB';
ALTER SYSTEM SET
 effective_cache_size = '12GB';
ALTER SYSTEM SET
 maintenance_work_mem = '1GB';
ALTER SYSTEM SET
 checkpoint_completion_target = '0.9';
ALTER SYSTEM SET
 wal_buffers = '24MB';
ALTER SYSTEM SET
 default_statistics_target = '100';
ALTER SYSTEM SET
 random_page_cost = '1.1';
ALTER SYSTEM SET
 effective_io_concurrency = '200';
ALTER SYSTEM SET
 work_mem = '10485kB';
ALTER SYSTEM SET
 huge_pages = 'off';
ALTER SYSTEM SET
 min_wal_size = '1GB';
ALTER SYSTEM SET
 max_wal_size = '4GB';
---

CREATE EXTENSION pgcrypto;
ALTER DATABASE nde SET synchronous_commit = off;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    balance INT DEFAULT 1000 NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE TABLE vulnerabilities (
    id SERIAL PRIMARY KEY,
    seller_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cve_code VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL UNIQUE,
    exploit TEXT NOT NULL UNIQUE,
    exploit_type VARCHAR(50) NOT NULL CHECK (
        exploit_type IN (
            'rce', 'sqli', 'xss', 'lfi', 'rfi', 'xxe', 'idor',
            'ssti', 'buffer_overflow', 'heap_overflow', 'format_string',
            'command_injection', 'privilege_escalation', 'auth_bypass',
            'logic_bug', 'crypto_attack', 'side_channel', 'hardware_exploit',
            'iot_exploit', 'smart_contract', 'deepfake_hack', 'other'
        )
    ) DEFAULT 'other',
    platform VARCHAR(255) NOT NULL CHECK (
        platform IN ('windows', 'linux', 'macos', 'android', 'ios', 'web', 'cloud', 'scada',
                 'iot', 'blockchain', 'hypervisor', 'network', 'firmware', 'game',
                 'drone', 'automotive')),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('none','low','medium','high','critical')) DEFAULT 'none',
    status VARCHAR(20) NOT NULL CHECK (status IN ('manual_review', 'available', 'sold', 'pending')) DEFAULT 'manual_review',
    price INT NOT NULL CHECK (price >= 0), -- Цена не может быть отрицательной
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    from_user INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vulnerability_id INT REFERENCES vulnerabilities(id) ON DELETE CASCADE,
    amount INT NOT NULL CHECK (amount > 0),
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('transfer', 'purchase', 'bonus')),
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE sessions (
    session_id TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT now()
);

-- Создаем пользователя для биржи, если его еще нет
INSERT INTO users (username, email, password_hash, balance, created_at)
VALUES (
  'Exchange Account',
  'exchange@ncem.com',
  crypt(md5(random()::text), gen_salt('bf')),
  1000000,  -- баланс для этого пользователя обычно нулевой
  now()
)
ON CONFLICT (email) DO NOTHING  -- если такой пользователь уже существует
RETURNING id;
