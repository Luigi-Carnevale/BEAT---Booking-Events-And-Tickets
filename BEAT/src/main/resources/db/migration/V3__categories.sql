-- V3__categories.sql
-- Add categories and link each event to one category (1-N)

CREATE TABLE categories (
                            id BIGINT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(50) NOT NULL,
                            CONSTRAINT uq_categories_name UNIQUE (name)
) ENGINE=InnoDB;

-- Add nullable first to avoid breaking existing rows if events already exist
ALTER TABLE events
    ADD COLUMN category_id BIGINT NULL;

-- Index + FK
CREATE INDEX ix_events_category_id ON events(category_id);

ALTER TABLE events
    ADD CONSTRAINT fk_events_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
            ON DELETE SET NULL
            ON UPDATE CASCADE;

-- Optional: seed common categories (edit as you like)
INSERT INTO categories(name) VALUES
                                 ('CONCERTO'),
                                 ('TEATRO'),
                                 ('SPORT'),
                                 ('MOSTRA'),
                                 ('FIERA'),
                                 ('ALTRO');
