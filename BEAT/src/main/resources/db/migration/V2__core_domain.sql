-- V2__core_domain.sql
-- Core domain schema: events, bookings, reviews

CREATE TABLE events (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,

                        title VARCHAR(100) NOT NULL,
                        event_date DATE NOT NULL,
                        event_time TIME NOT NULL,
                        location VARCHAR(100) NOT NULL,
                        protagonist VARCHAR(100) NULL,

                        is_fair TINYINT(1) NOT NULL DEFAULT 0,
                        description TEXT NULL,
                        image_url VARCHAR(255) NULL,

                        total_seats INT NOT NULL,
                        available_seats INT NOT NULL,

                        price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
                        is_free TINYINT(1) NOT NULL DEFAULT 0,

                        organizer_id BIGINT NOT NULL,

                        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                        CONSTRAINT fk_events_organizer
                            FOREIGN KEY (organizer_id) REFERENCES users(id)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE,

                        CONSTRAINT chk_seats_nonneg CHECK (total_seats >= 0 AND available_seats >= 0),
                        CONSTRAINT chk_seats_le_total CHECK (available_seats <= total_seats),
                        CONSTRAINT chk_price_nonneg CHECK (price >= 0),
                        CONSTRAINT chk_free_price CHECK ((is_free = 1 AND price = 0.00) OR (is_free = 0))
) ENGINE=InnoDB;

CREATE INDEX ix_events_date ON events(event_date);
CREATE INDEX ix_events_organizer_id ON events(organizer_id);

CREATE TABLE bookings (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,

                          user_id BIGINT NOT NULL,
                          event_id BIGINT NOT NULL,

                          quantity INT NOT NULL DEFAULT 1,
                          status ENUM('CREATED','PAID','CANCELLED','FAILED') NOT NULL DEFAULT 'CREATED',

                          purchased_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          unique_code VARCHAR(50) NOT NULL,

                          CONSTRAINT fk_bookings_user
                              FOREIGN KEY (user_id) REFERENCES users(id)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,

                          CONSTRAINT fk_bookings_event
                              FOREIGN KEY (event_id) REFERENCES events(id)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,

                          CONSTRAINT uq_bookings_code UNIQUE (unique_code),
                          CONSTRAINT chk_booking_qty CHECK (quantity > 0 AND quantity <= 4)
) ENGINE=InnoDB;

CREATE INDEX ix_bookings_user_id ON bookings(user_id);
CREATE INDEX ix_bookings_event_id ON bookings(event_id);

CREATE TABLE reviews (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,

                         user_id BIGINT NOT NULL,
                         event_id BIGINT NOT NULL,

                         rating TINYINT NOT NULL,
                         content TEXT NULL,
                         created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

                         CONSTRAINT fk_reviews_user
                             FOREIGN KEY (user_id) REFERENCES users(id)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE,

                         CONSTRAINT fk_reviews_event
                             FOREIGN KEY (event_id) REFERENCES events(id)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE,

                         CONSTRAINT uq_reviews_user_event UNIQUE (user_id, event_id),
                         CONSTRAINT chk_rating CHECK (rating >= 1 AND rating <= 5)
) ENGINE=InnoDB;

CREATE INDEX ix_reviews_event_id ON reviews(event_id);
CREATE INDEX ix_reviews_user_id ON reviews(user_id);
