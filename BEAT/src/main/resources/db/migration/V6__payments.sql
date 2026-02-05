-- V6__payments.sql
-- Payments: track payment and refunds (mockable gateway)

CREATE TABLE payments (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,

                          booking_id BIGINT NOT NULL,

                          type ENUM('PAYMENT','REFUND') NOT NULL DEFAULT 'PAYMENT',
                          provider VARCHAR(30) NOT NULL DEFAULT 'MOCK',

                          transaction_id VARCHAR(100) NOT NULL,
                          amount DECIMAL(10,2) NOT NULL,

                          status ENUM('CREATED','AUTHORIZED','CAPTURED','FAILED','REFUNDED') NOT NULL DEFAULT 'CREATED',

                          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                          CONSTRAINT fk_payments_booking
                              FOREIGN KEY (booking_id) REFERENCES bookings(id)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,

                          CONSTRAINT uq_payments_transaction UNIQUE (transaction_id)
) ENGINE=InnoDB;

CREATE INDEX ix_payments_booking_id ON payments(booking_id);
CREATE INDEX ix_payments_status ON payments(status);
CREATE INDEX ix_payments_type ON payments(type);
