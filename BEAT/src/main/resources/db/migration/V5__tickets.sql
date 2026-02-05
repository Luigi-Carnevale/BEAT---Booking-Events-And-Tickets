-- V5__tickets.sql
-- Tickets: one ticket per seat purchased (booking.quantity)

CREATE TABLE tickets (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,

                         booking_id BIGINT NOT NULL,

                         ticket_code VARCHAR(64) NOT NULL,
                         status ENUM('ISSUED','USED','CANCELLED') NOT NULL DEFAULT 'ISSUED',

                         issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         used_at DATETIME NULL DEFAULT NULL,

                         CONSTRAINT fk_tickets_booking
                             FOREIGN KEY (booking_id) REFERENCES bookings(id)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE,

                         CONSTRAINT uq_tickets_code UNIQUE (ticket_code)
) ENGINE=InnoDB;

CREATE INDEX ix_tickets_booking_id ON tickets(booking_id);
CREATE INDEX ix_tickets_status ON tickets(status);
