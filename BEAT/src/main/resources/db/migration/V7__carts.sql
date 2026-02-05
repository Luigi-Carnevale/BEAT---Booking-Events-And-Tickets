-- V7__carts.sql
-- Carts + cart items

CREATE TABLE carts (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,

                       user_id BIGINT NOT NULL,
                       status ENUM('OPEN','CHECKED_OUT','ABANDONED') NOT NULL DEFAULT 'OPEN',

                       created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                       CONSTRAINT fk_carts_user
                           FOREIGN KEY (user_id) REFERENCES users(id)
                               ON DELETE RESTRICT
                               ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_carts_user_id ON carts(user_id);
CREATE INDEX ix_carts_status ON carts(status);

CREATE TABLE cart_items (
                            cart_id BIGINT NOT NULL,
                            event_id BIGINT NOT NULL,

                            quantity INT NOT NULL DEFAULT 1,
                            unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,

                            PRIMARY KEY (cart_id, event_id),

                            CONSTRAINT fk_cart_items_cart
                                FOREIGN KEY (cart_id) REFERENCES carts(id)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE,

                            CONSTRAINT fk_cart_items_event
                                FOREIGN KEY (event_id) REFERENCES events(id)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_cart_items_event_id ON cart_items(event_id);
