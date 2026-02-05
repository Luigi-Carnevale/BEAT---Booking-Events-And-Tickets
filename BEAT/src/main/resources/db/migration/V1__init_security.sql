-- V1__init_security.sql
-- Core security schema: users, roles, user_roles

CREATE TABLE users (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       username VARCHAR(30) NOT NULL,
                       email VARCHAR(100) NOT NULL,
                       password_hash CHAR(60) NOT NULL,         -- BCrypt hash = 60 chars
                       is_active TINYINT(1) NOT NULL DEFAULT 1,
                       created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

                       CONSTRAINT uq_users_username UNIQUE (username),
                       CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE roles (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       name VARCHAR(32) NOT NULL,
                       CONSTRAINT uq_roles_name UNIQUE (name)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
                            user_id BIGINT NOT NULL,
                            role_id BIGINT NOT NULL,
                            PRIMARY KEY (user_id, role_id),

                            CONSTRAINT fk_user_roles_user
                                FOREIGN KEY (user_id) REFERENCES users(id)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE,

                            CONSTRAINT fk_user_roles_role
                                FOREIGN KEY (role_id) REFERENCES roles(id)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_user_roles_role_id ON user_roles(role_id);

-- Seed roles (SDD/RAD)
INSERT INTO roles(name) VALUES
                            ('CLIENTE'),
                            ('ORGANIZZATORE'),
                            ('ADMIN_CATALOGO'),
                            ('ADMIN_ORDINI'),
                            ('ADMIN_RUOLI');
