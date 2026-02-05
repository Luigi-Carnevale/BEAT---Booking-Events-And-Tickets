-- V4__locations.sql
-- Add locations table and reference it from events

CREATE TABLE locations (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           name VARCHAR(100) NOT NULL,
                           address VARCHAR(150) NULL,
                           city VARCHAR(80) NOT NULL,
                           CONSTRAINT uq_locations UNIQUE (name, city, address)
) ENGINE=InnoDB;

ALTER TABLE events
    ADD COLUMN location_id BIGINT NULL;

CREATE INDEX ix_events_location_id ON events(location_id);

ALTER TABLE events
    ADD CONSTRAINT fk_events_location
        FOREIGN KEY (location_id) REFERENCES locations(id)
            ON DELETE SET NULL
            ON UPDATE CASCADE;

-- (Opzionale) Se vuoi migrare i dati dal vecchio campo testuale:
-- 1) inserisci locations distinte
-- 2) aggiorna events.location_id
-- Questa parte dipende da come è formattato events.location, quindi meglio farla a mano.
