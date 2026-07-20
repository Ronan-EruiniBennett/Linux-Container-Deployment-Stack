CREATE TABLE heartbeats(
    heartbeat_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id Varchar NOT NULL,
    heartbeat_time TIMESTAMP DEFAULT now() NOT NULL,
    device_status Varchar NOT NULL 
);

CREATE INDEX idx_heartbeats_device_time
    ON heartbeats (device_id, heartbeat_time DESC);