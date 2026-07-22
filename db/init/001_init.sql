CREATE TABLE heartbeats(
    heartbeat_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    server_id Varchar NOT NULL,
    received_at TIMESTAMP DEFAULT now() NOT NULL,
    server_status Varchar NOT NULL 
);

CREATE INDEX idx_heartbeats_server_time
    ON heartbeats (server_id, received_at DESC);